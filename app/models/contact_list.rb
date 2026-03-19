class ContactList < ApplicationRecord
  has_many :contacts, dependent: :nullify

  validates :name, presence: true

  def contacts_count
    contacts.count
  end

  def active_contacts_count
    contacts.where(active: true).count
  end
end
