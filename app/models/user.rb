class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  ROLES = %w[admin ceo coo cto cfo hr manager basic].freeze

  has_many :announcements, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :audience_memberships, dependent: :destroy
  has_many :audiences, through: :audience_memberships
  has_many :created_audiences, class_name: "Audience", foreign_key: :created_by_id, dependent: :nullify

  def has_role?(*roles)
    roles.map!(&:to_s)
    roles.include?(role)
  end

  def admin?
    role == "admin"
  end
end
