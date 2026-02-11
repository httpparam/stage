class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  before_action :require_logged_in_user!
  before_action :require_complete_profile!

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    require_logged_in_user!
  end

  def require_logged_in_user!
    unless current_user
      redirect_to new_session_path, alert: "Please sign in to continue."
    end
  end

  def require_complete_profile!
    return unless current_user
    return if controller_name == "profiles" || controller_name == "sessions"

    unless current_user.profile_complete?
      redirect_to edit_profile_path, notice: "Please complete your profile to continue."
    end
  end
end
