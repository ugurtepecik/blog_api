# typed: false

class User < ApplicationRecord
  has_secure_password

  scope :by_email_domain, ->(domain) { where('email LIKE ?', "%@#{domain}%") }

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 6 }, if: ->(record) { record.new_record? || !record.password.nil? }
end
