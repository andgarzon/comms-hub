# config/initializers/openai.rb
require "ruby/openai"

# OpenAI credentials are managed via IntegrationSetting (database, encrypted).
# Service classes read directly from the DB at runtime.
# No global OpenAI.configure needed — each client instance uses its own token.
