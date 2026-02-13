class IntegrationSetting < ApplicationRecord
  PROVIDERS = %w[openai slack whatsapp email].freeze

  validates :provider, presence: true, uniqueness: true, inclusion: { in: PROVIDERS }
  validates :status, inclusion: { in: %w[active inactive error] }

  # Encrypt the entire config_data JSON blob at rest
  encrypts :config_data

  # Serialize config_data as JSON (since encrypts converts to string)
  serialize :config_data, coder: JSON

  # ------------------------------------------------------------------
  # Convenience class methods
  # ------------------------------------------------------------------

  def self.for(provider)
    find_or_initialize_by(provider: provider.to_s)
  end

  def self.get(provider, key)
    setting = find_by(provider: provider.to_s)
    return nil unless setting
    setting.setting(key)
  end

  # ------------------------------------------------------------------
  # Instance helpers
  # ------------------------------------------------------------------

  def setting(key)
    (config_data || {})[key.to_s]
  end

  def set(key, value)
    self.config_data ||= {}
    self.config_data[key.to_s] = value
  end

  def configured?
    status == "active"
  end

  def mark_active!
    update!(status: "active", last_error: nil)
  end

  def mark_error!(message)
    update!(status: "error", last_error: message)
  end

  def mark_inactive!
    update!(status: "inactive", last_error: nil)
  end

  # ------------------------------------------------------------------
  # Provider-specific convenience readers
  # ------------------------------------------------------------------

  # OpenAI
  def api_key;         setting("api_key"); end
  def organization_id; setting("organization_id"); end
  def model_name;      setting("model_name") || "gpt-4o-mini"; end

  # Slack
  def bot_token;       setting("bot_token"); end
  def default_channel; setting("default_channel"); end

  # WhatsApp
  def phone_number_id;     setting("phone_number_id"); end
  def access_token;        setting("access_token"); end
  def business_account_id; setting("business_account_id"); end
  def sender_phone;        setting("sender_phone"); end

  # Email / SMTP
  def from_email;           setting("from_email"); end
  def smtp_address;         setting("smtp_address"); end
  def smtp_port;            setting("smtp_port"); end
  def smtp_domain;          setting("smtp_domain"); end
  def smtp_username;        setting("smtp_username"); end
  def smtp_password;        setting("smtp_password"); end
  def smtp_authentication;  setting("smtp_authentication"); end

  # ------------------------------------------------------------------
  # Masked display helpers (never show full secrets in UI)
  # ------------------------------------------------------------------

  def masked_api_key
    mask(api_key)
  end

  def masked_bot_token
    mask(bot_token)
  end

  def masked_access_token
    mask(access_token)
  end

  def masked_smtp_password
    mask(smtp_password)
  end

  private

  def mask(value)
    return nil if value.blank?
    return value if value.length <= 8
    "#{value[0..3]}#{'*' * [value.length - 8, 4].max}#{value[-4..]}"
  end
end
