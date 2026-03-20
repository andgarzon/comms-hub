class Contact < ApplicationRecord
  CONTACT_TYPES = %w[client vendor admin_staff client_staff slack_channel].freeze

  belongs_to :contact_list, optional: true
  has_many :audience_contacts, dependent: :destroy
  has_many :audiences, through: :audience_contacts

  validates :name, presence: true
  validates :contact_type, inclusion: { in: CONTACT_TYPES }, allow_blank: true
  validates :slack_channel, presence: true, if: -> { contact_type == "slack_channel" }

  def slack_channel_type?
    contact_type == "slack_channel"
  end

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_company, ->(company) { where(company: company) }
  scope :by_department, ->(dept) { where(department: dept) }
  scope :by_type, ->(type) { where(contact_type: type) }
  scope :by_list, ->(list_id) { where(contact_list_id: list_id) }
  scope :search, ->(q) {
    where("contacts.name ILIKE :q OR contacts.email ILIKE :q OR contacts.company ILIKE :q OR contacts.department ILIKE :q", q: "%#{q}%")
  }

  def display_type
    contact_type&.titleize || "Admin Staff"
  end

  def active_label
    active? ? "Active" : "Inactive"
  end
end
