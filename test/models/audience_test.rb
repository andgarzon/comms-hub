require "test_helper"

class AudienceTest < ActiveSupport::TestCase
  test "contact_slack_usernames returns unique slack usernames for active contacts" do
    audience = SlackAudience.create!(name: "Test", slack_channel: "#test", scope_type: "personal")
    contact_with_slack = contacts(:slack_contact)
    contact_without_slack = contacts(:no_slack_contact)

    audience.contacts << contact_with_slack
    audience.contacts << contact_without_slack

    usernames = audience.contact_slack_usernames
    assert_includes usernames, contact_with_slack.slack_username
    assert_not_includes usernames, nil
    assert_equal usernames, usernames.uniq
  end
end
