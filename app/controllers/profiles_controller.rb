class ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :require_complete_profile!, only: %i[edit update]

  def show
  end

  def edit
  end

  def update
    if current_user.update(profile_params)
      if current_user.profile_complete?
        redirect_to dashboard_path, notice: "Profile completed successfully. Welcome aboard!"
      else
        redirect_to edit_profile_path, alert: "Please fill in your first name and age."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :age)
  end
end
