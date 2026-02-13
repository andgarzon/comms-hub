class IntegrationsController < ApplicationController
  before_action :authorize_admin!

  def index
    @openai_setting   = IntegrationSetting.for("openai")
    @slack_setting    = IntegrationSetting.for("slack")
    @whatsapp_setting = IntegrationSetting.for("whatsapp")
    @email_setting    = IntegrationSetting.for("email")
  end

  # ---------- OpenAI ----------

  def openai
    @setting = IntegrationSetting.for("openai")
  end

  def update_openai
    setting = IntegrationSetting.for("openai")
    setting.config_data = {
      "api_key"         => params[:api_key],
      "organization_id" => params[:organization_id],
      "model_name"      => params[:model_name].presence || "gpt-4o-mini"
    }

    if params[:api_key].present?
      setting.status = "active"
      setting.last_error = nil
    else
      setting.status = "inactive"
    end

    setting.save!
    redirect_to openai_integration_path, notice: "OpenAI settings saved."
  end

  def test_openai
    setting = IntegrationSetting.for("openai")
    unless setting.api_key.present?
      render json: { success: false, message: "No API key configured." }
      return
    end

    begin
      client = OpenAI::Client.new(access_token: setting.api_key)
      resp = client.chat(
        parameters: {
          model: setting.model_name,
          messages: [{ role: "user", content: "Say 'OK' if you can hear me." }],
          max_tokens: 10
        }
      )
      content = resp.dig("choices", 0, "message", "content")
      setting.update!(status: "active", last_error: nil, last_tested_at: Time.current)
      render json: { success: true, message: "Connected! Response: #{content}" }
    rescue => e
      setting.update!(status: "error", last_error: e.message, last_tested_at: Time.current)
      render json: { success: false, message: "Connection failed: #{e.message}" }
    end
  end

  # ---------- Slack ----------

  def slack
    @setting = IntegrationSetting.for("slack")
  end

  def update_slack
    setting = IntegrationSetting.for("slack")
    setting.config_data = {
      "bot_token"       => params[:bot_token],
      "default_channel" => params[:default_channel]
    }

    if params[:bot_token].present?
      setting.status = "active"
      setting.last_error = nil
    else
      setting.status = "inactive"
    end

    setting.save!
    redirect_to slack_integration_path, notice: "Slack settings saved."
  end

  def test_slack
    setting = IntegrationSetting.for("slack")
    unless setting.bot_token.present?
      render json: { success: false, message: "No bot token configured." }
      return
    end

    begin
      client = Slack::Web::Client.new(token: setting.bot_token)
      info = client.auth_test
      setting.update!(status: "active", last_error: nil, last_tested_at: Time.current)
      render json: { success: true, message: "Connected as #{info['user']} in #{info['team']}." }
    rescue => e
      setting.update!(status: "error", last_error: e.message, last_tested_at: Time.current)
      render json: { success: false, message: "Connection failed: #{e.message}" }
    end
  end

  # ---------- WhatsApp ----------

  def whatsapp
    @setting = IntegrationSetting.for("whatsapp")
  end

  def update_whatsapp
    setting = IntegrationSetting.for("whatsapp")
    setting.config_data = {
      "phone_number_id"     => params[:phone_number_id],
      "access_token"        => params[:access_token],
      "business_account_id" => params[:business_account_id],
      "sender_phone"        => params[:sender_phone]
    }

    if params[:phone_number_id].present? && params[:access_token].present?
      setting.status = "active"
      setting.last_error = nil
    else
      setting.status = "inactive"
    end

    setting.save!
    redirect_to whatsapp_integration_path, notice: "WhatsApp settings saved."
  end

  def test_whatsapp
    setting = IntegrationSetting.for("whatsapp")
    unless setting.access_token.present? && setting.phone_number_id.present?
      render json: { success: false, message: "Missing credentials. Configure Phone Number ID and Access Token first." }
      return
    end

    begin
      uri = URI("https://graph.facebook.com/v18.0/#{setting.phone_number_id}")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{setting.access_token}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

      if res.code.to_i == 200
        setting.update!(status: "active", last_error: nil, last_tested_at: Time.current)
        render json: { success: true, message: "Connected to WhatsApp Cloud API." }
      else
        error_msg = "HTTP #{res.code}: #{res.body}"
        setting.update!(status: "error", last_error: error_msg, last_tested_at: Time.current)
        render json: { success: false, message: "Connection failed: #{error_msg}" }
      end
    rescue => e
      setting.update!(status: "error", last_error: e.message, last_tested_at: Time.current)
      render json: { success: false, message: "Connection failed: #{e.message}" }
    end
  end

  # ---------- Email / SMTP ----------

  def email
    @setting = IntegrationSetting.for("email")
  end

  def update_email
    setting = IntegrationSetting.for("email")
    setting.config_data = {
      "from_email"           => params[:from_email],
      "smtp_address"         => params[:smtp_address],
      "smtp_port"            => params[:smtp_port],
      "smtp_domain"          => params[:smtp_domain],
      "smtp_username"        => params[:smtp_username],
      "smtp_password"        => params[:smtp_password],
      "smtp_authentication"  => params[:smtp_authentication]
    }

    if params[:from_email].present? && params[:smtp_address].present?
      setting.status = "active"
      setting.last_error = nil
    else
      setting.status = "inactive"
    end

    setting.save!

    # Dynamically apply SMTP settings so restarts aren't needed
    apply_smtp_settings(setting)

    redirect_to email_integration_path, notice: "Email settings saved."
  end

  private

  def apply_smtp_settings(setting)
    return unless setting.configured?

    ActionMailer::Base.smtp_settings = {
      address: setting.smtp_address,
      port: setting.smtp_port.to_i,
      domain: setting.smtp_domain,
      user_name: setting.smtp_username,
      password: setting.smtp_password,
      authentication: setting.smtp_authentication&.to_sym || :plain,
      enable_starttls_auto: true
    }
    ActionMailer::Base.default_options = { from: setting.from_email }
  end
end
