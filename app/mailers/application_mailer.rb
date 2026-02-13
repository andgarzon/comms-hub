class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  # Dynamic from address: reads from IntegrationSetting at send time
  default from: -> { email_from_address }

  private

  def email_from_address
    setting = IntegrationSetting.find_by(provider: "email")
    setting&.from_email.presence || "noreply@commshub.app"
  end
end
