# config/initializers/smtp.rb
#
# Load SMTP settings from IntegrationSetting (database) on app boot.
# These can be updated at runtime from the Integrations > Email config page.

Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists?("integration_settings")
    setting = IntegrationSetting.find_by(provider: "email")
    if setting&.configured? && setting.smtp_address.present?
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        address: setting.smtp_address,
        port: setting.smtp_port.to_i,
        domain: setting.smtp_domain,
        user_name: setting.smtp_username,
        password: setting.smtp_password,
        authentication: setting.smtp_authentication&.to_sym || :plain,
        enable_starttls_auto: true
      }
      Rails.logger.info("SMTP configured from database: #{setting.smtp_address}:#{setting.smtp_port}")
    else
      Rails.logger.info("SMTP not configured in database. Using Rails defaults.")
    end
  end
rescue => e
  Rails.logger.warn("Could not load SMTP settings from database: #{e.message}")
end
