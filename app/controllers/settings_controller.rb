class SettingsController < ApplicationController
  def index
    @user_count = User.count
    # Placeholder: integration settings will be loaded when models are created
    @whatsapp_setting = nil
  end
end
