class NotificationPreference < ApplicationRecord
  belongs_to :user

  def self.for(user)
    find_or_create_by(user: user)
  end

  def wants_email?(event)
    case event
    when :sent then email_on_sent
    when :failed then email_on_failure
    else false
    end
  end

  def wants_in_app?(event)
    case event
    when :sent then in_app_on_sent
    when :failed then in_app_on_failure
    else false
    end
  end
end
