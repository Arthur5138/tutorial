class User < ApplicationRecord
  attr_accessor :remember_token #has_secure_passwordの時は仮想のpassword属性ができたが、今回は自分で仮想属性を作成する必要がある
  before_save { self.email = self.email.downcase } #セーブをする前に小文字にする。右selfは現在のユーザーを指す。
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }
  #uniquenessでemaiの一意性とcase_sensitiveで大文字小文字を無視
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
   # 永続セッションのためにユーザーをデータベースに記憶する
   def remember
     self.remember_token = User.new_token
     update_attribute(:remember_digest, User.digest(remember_token))
   end
   
   # 渡されたトークンがダイジェストと一致したらtrueを返す
   
   def authenticated?(remember_token)
       return false if remember_digest.nil? #userのremember_digestがnilの場合はfalseを返す。return falseでメソッドを即座に終了。return falseしない場合nilだと例外が起きる
       BCrypt::Password.new(remember_digest).is_password?(remember_token)
   end
   
   def forget
     update_attribute(:remember_digest, nil)
   end
end
