class SlackAudience < Audience
  validates :name, presence: true
  validates :slack_channel, presence: true
end