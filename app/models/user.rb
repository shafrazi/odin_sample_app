class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_secure_password

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    self.update_attribute(:remember_digest, User.digest(remember_token))
  end

  # forgets a user
  def forget
    self.update_attribute(:remember_digest, nil)
  end

  # returns true if the given token matches the digest in database
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    if digest.nil?
      false
    else
      BCrypt::Password.new(digest).is_password?(token)
    end
  end

  def activate
    self.update_attribute(:activated, true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # sets password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    # self.update_attribute(:reset_digest, User.digest(self.reset_token))
    # self.update_attribute(:reset_sent_at, Time.zone.now)
    self.update_columns(reset_digest: User.digest(self.reset_token), reset_sent_at: Time.zone.now)
  end

  # sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # returns true if password reset has expired
  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  # follows a user
  def follow(other_user)
    self.following << other_user
  end

  # checks whether a user is following another user
  def following?(other_user)
    self.following.include?(other_user)
  end

  # unfollows a user
  def unfollow(other_user)
    self.following.delete(other_user)
  end

  # returns a user's status feed
  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: self.id)
  end

  private

  def downcase_email
    self.email = self.email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
