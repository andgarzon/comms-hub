class NotificationPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @preference = NotificationPreference.for(current_user)
  end

  def update
    @preference = NotificationPreference.for(current_user)

    if @preference.update(preference_params)
      redirect_to edit_notification_preferences_path, notice: "Notification preferences saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:notification_preference).permit(
      :email_on_sent, :email_on_failure,
      :in_app_on_sent, :in_app_on_failure
    )
  end
end
