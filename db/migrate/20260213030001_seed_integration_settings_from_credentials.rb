class SeedIntegrationSettingsFromCredentials < ActiveRecord::Migration[8.1]
  def up
    # Import existing credentials into integration_settings table.
    # After this migration, the app reads from the DB and credentials can be removed.

    # OpenAI
    openai_key = Rails.application.credentials.dig(:openai, :api_key)
    openai_org = Rails.application.credentials.dig(:openai, :organization_id)
    if openai_key.present?
      setting = IntegrationSetting.find_or_initialize_by(provider: "openai")
      setting.config_data = {
        "api_key" => openai_key,
        "organization_id" => openai_org,
        "model_name" => "gpt-4o-mini"
      }
      setting.status = "active"
      setting.save!
      say "  -> Imported OpenAI credentials"
    end

    # Slack
    slack_token = Rails.application.credentials.dig(:slack, :bot_token)
    slack_channel = Rails.application.credentials.dig(:slack, :default_channel)
    if slack_token.present?
      setting = IntegrationSetting.find_or_initialize_by(provider: "slack")
      setting.config_data = {
        "bot_token" => slack_token,
        "default_channel" => slack_channel
      }
      setting.status = "active"
      setting.save!
      say "  -> Imported Slack credentials"
    end

    # Email / Gmail SMTP
    gmail_user = Rails.application.credentials.dig(:gmail, :user_name)
    gmail_pass = Rails.application.credentials.dig(:gmail, :password)
    if gmail_user.present?
      setting = IntegrationSetting.find_or_initialize_by(provider: "email")
      setting.config_data = {
        "from_email" => gmail_user,
        "smtp_address" => "smtp.gmail.com",
        "smtp_port" => "587",
        "smtp_domain" => "gmail.com",
        "smtp_username" => gmail_user,
        "smtp_password" => gmail_pass,
        "smtp_authentication" => "plain"
      }
      setting.status = "active"
      setting.save!
      say "  -> Imported Email/SMTP credentials"
    end

    # WhatsApp (initialize as inactive if no credentials exist)
    unless IntegrationSetting.exists?(provider: "whatsapp")
      IntegrationSetting.create!(
        provider: "whatsapp",
        config_data: {},
        status: "inactive"
      )
      say "  -> Created WhatsApp placeholder (not configured)"
    end
  end

  def down
    IntegrationSetting.destroy_all
  end
end
