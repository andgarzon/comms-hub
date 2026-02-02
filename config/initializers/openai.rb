# config/initializers/openai.rb
require "ruby/openai"

OPENAI_API_KEY =
  ENV["OPENAI_ACCESS_TOKEN"] ||
  ENV["OPENAI_API_KEY"] ||
  Rails.application.credentials.dig(:openai, :api_key)

if OPENAI_API_KEY.present?
  OpenAI.configure do |config|
    config.access_token = Rails.application.credentials.dig(:openai, :api_key)
    config.organization_id = Rails.application.credentials.dig(:openai, :organization_id)
  end
else
  Rails.logger.warn("OpenAI not configured: set OPENAI_ACCESS_TOKEN/OPENAI_API_KEY or credentials openai.api_key")
end
