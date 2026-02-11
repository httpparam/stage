class SessionsController < ApplicationController
  skip_before_action :require_logged_in_user!, only: %i[new create edit update]

  before_action :redirect_if_authenticated, only: %i[new create edit update]
  before_action :set_user_by_email_token, only: %i[edit update]

  def new
  end

  def create
    @email = params[:email].to_s.downcase.strip

    if @email.blank? || !@email.match?(URI::MailTo::EMAIL_REGEXP)
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "Please enter a valid email address." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Please enter a valid email address." }) }
      end
      return
    end

    @user = User.find_or_create_by_email(@email)

    # Rate limiting: max 1 OTP per minute
    if @user.otp_sent_at && @user.otp_sent_at > 1.minute.ago
      respond_to do |format|
        format.html { redirect_to new_session_path, alert: "Please wait before requesting another code." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Please wait before requesting another code." }) }
      end
      return
    end

    @otp_code = @user.generate_otp!
    AuthenticationMailer.login_otp(@user.email, @otp_code).deliver_later

    respond_to do |format|
      format.html { redirect_to edit_session_path(email_token: @user.id) }
      format.turbo_stream
    end
  end

  def edit
  end

  def update
    if @user&.verify_otp?(params[:otp_code].to_s.gsub(/\D/, ""))
      session[:user_id] = @user.id
      if @user.first_name.blank? || @user.age.blank?
        redirect_to edit_profile_path, notice: "Welcome! Please complete your profile to continue."
      else
        redirect_to dashboard_path, notice: "Welcome back, #{@user.display_name}!"
      end
    else
      @error = "Invalid or expired code. Please try again."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "You have been signed out."
  end

  private

  def redirect_if_authenticated
    redirect_to dashboard_path if current_user
  end

  def set_user_by_email_token
    @user = User.find_by(id: params[:email_token])
    unless @user
      redirect_to new_session_path, alert: "Session expired. Please request a new code."
    end
  end
end
