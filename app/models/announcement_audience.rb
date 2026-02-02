class AnnouncementAudience < ApplicationRecord
  belongs_to :announcement
  belongs_to :audience
end
