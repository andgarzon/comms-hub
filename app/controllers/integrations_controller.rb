class IntegrationsController < ApplicationController
  def index
    # Placeholder: these will be loaded when setting models are created
    @openai_setting = OpenStruct.new(configured?: false, last_error: nil)
    @whatsapp_setting = OpenStruct.new(configured?: false, last_error: nil)
    @slack_setting = OpenStruct.new(configured?: false, last_error: nil)
    @email_setting = OpenStruct.new(configured?: false, last_error: nil)
  end

  def openai
    @setting = OpenStruct.new(configured?: false, last_error: nil, api_key: nil, organization_id: nil, model_name: nil, last_tested_at: nil)
  end

  def whatsapp
    @setting = OpenStruct.new(configured?: false, last_error: nil, phone_number_id: nil, access_token: nil, business_account_id: nil, sender_phone: nil, last_tested_at: nil)
  end

  def slack
    @setting = OpenStruct.new(configured?: false, last_error: nil, bot_token: nil, last_tested_at: nil)
    @setting.define_singleton_method(:setting) { |_key| nil }
  end

  def email
    @setting = OpenStruct.new(configured?: false, last_error: nil, from_email: nil, smtp_address: nil, smtp_port: nil, smtp_domain: nil, smtp_username: nil, smtp_password: nil, smtp_authentication: nil)
  end

  def update_openai
    redirect_to openai_integration_path, notice: "OpenAI settings saved."
  end

  def update_whatsapp
    redirect_to whatsapp_integration_path, notice: "WhatsApp settings saved."
  end

  def update_slack
    redirect_to slack_integration_path, notice: "Slack settings saved."
  end

  def update_email
    redirect_to email_integration_path, notice: "Email settings saved."
  end

  def test_openai
    render json: { success: false, message: "OpenAI integration not yet configured." }
  end

  def test_whatsapp
    render json: { success: false, message: "WhatsApp integration not yet configured." }
  end

  def test_slack
    render json: { success: false, message: "Slack integration not yet configured." }
  end
end
