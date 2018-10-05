class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 上記active_relationshipモデルは無いので、class_name：で明示的に探して欲しいモデルのクラス名を表記する今回の場合Relationshipモデルは存在する
  has_many :following, through: :active_relationships, source: :followed
  
  
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token #has_secure_passwordの時は仮想のpassword属性ができたが、今回は自分で仮想属性を作成する必要がある
  #before_save { self.email = self.email.downcase } #セーブをする前に小文字にする。右selfは現在のユーザーを指す。
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }
  #uniquenessでemaiの一意性とcase_sensitiveで大文字小文字を無視
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
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
   
   def authenticated?(attribute, token)
       digest = self.send("#{attribute}_digest") #sendメソッドに式展開_digestを渡してる 11.26参照
       return false if digest.nil? #userのremember_digestがnilの場合はfalseを返す。return falseでメソッドを即座に終了。return falseしない場合nilだと例外が起きる
       BCrypt::Password.new(digest).is_password?(token)
   end
   
   def forget
     update_attribute(:remember_digest, nil)
   end
   
    
   def activate  #アカウントの有効化
     #update_attribute(:activated, true)
     #update_attribute(:activated_at, Time.zone.now)
     update_columns(activated: true, activated_at: Time.zone.now) #上の2行だとDBにupdateで2回アクセスするので1回にまとめる
   end
   
   def send_activation_email #有効化用のメールを送信する
     UserMailer.account_activation(self).deliver_now
   end
   
   
    #パスワードリセット設定
    
   def create_reset_digest #パスワードリセットのトークンを作成、digestに保存、タイムスタンプの更新（リセットメールに有効時間を設定させるため)
     self.reset_token = User.new_token
     update_attribute(:reset_digest, User.digest(reset_token))
     update_attribute(:reset_sent_at, Time.zone.now)
   end
   
   def send_password_reset_email #パスワード再設定のメールを送信する
     UserMailer.password_reset(self).deliver_now
   end
   
   def password_reset_expired?  # パスワード再設定の期限が切れている場合はtrueを返す
     reset_sent_at < 2.hours.ago
   end
   
   #マイクロポストのfeed用のメソッド
   
   #def feed
     #Micropost.where("user_id = ?", id)
   #end
   
   #ユーザーをフォローする
   def follow(other_user)
     following << other_user #followingでフォローしている集合体をgetして other_userを配列の最後に追加している。
   end
   
   #ユーザーのステータスフィードを返す
   #def feed
     #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
   #end
   
   def feed
     following_ids = "SELECT followed_id FROM relationships
                       WHERE follower_id = :user_id"
     Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
   end
   
   #ユーザーをフォロー解除している
   def unfollow(other_user)
     active_relationships.find_by(followed_id: other_user.id).destroy
   end
   
   #現在のユーザーがフォローしてたらTRUEを返す
   def following?(other_user)
     following.include?(other_user)
   end

   
   private
   
   def downcase_email #メールアドレスを小文字にする
    self.email = email.downcase
   end
   
   def create_activation_digest #有効化トークンとダイジェストを作成及び代入する。
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
   end
   
end
