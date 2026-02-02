class AnnouncementTarget < ApplicationRecord
  belongs_to :announcement
  belongs_to :group
end
