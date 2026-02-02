class AudienceMembership < ApplicationRecord
  belongs_to :audience
  belongs_to :user
end
