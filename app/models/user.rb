class User < ApplicationRecord
  before_save { self.email = self.email.downcase } #セーブをする前に小文字にする。右selfは現在のユーザーを指す。
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }
  #uniquenessでemaiの一意性とcase_sensitiveで大文字小文字を無視
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
