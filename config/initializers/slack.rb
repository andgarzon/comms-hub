# config/initializers/slack.rb
#
# Slack credentials are managed via IntegrationSetting (database, encrypted).
# SlackAnnouncementSender reads the bot token from the DB at runtime
# and creates its own Slack::Web::Client with the stored token.
# No global Slack.configure needed.
