class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships,  class_name: "Relationship",
                                    foreign_key: "followed_id",
                                    dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email # { email.downcase! }  # { self.email = email.downcase }
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\Z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Return the hash digest of the given string
  def self.digest(string) # User digest(string) 
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token
  def self.new_token # User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # Forget a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activate an account
  def activate
    update_columns( activated: true,             # update_attribute(:activated, true)
                    activated_at: Time.zone.now) # update_attribute(:activated_at, Time.zone.now)
  end

  # Send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns( reset_digest: User.digest(reset_token),   # update_attribute(:reset_digest, User.digest(reset_token))
                    reset_sent_at: Time.zone.now)             # update_attribute(:reset_sent_at, Time.zone.now)
  end
  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reste has expired
  def password_reset_expired?
    reset_sent_at < 2.hour.ago
  end

  # See "Following users" for the full implementation
  def feed
    # V1        => Micropost.where("user_id = ?", id)
    # V2(p773)  => Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # V3 (p775) => Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
                  # following_ids: following_ids, user_id: id)
    # V4 (p776) => :
    # following_ids =   "SELECT followed_id FROM relationships
                      # WHERE follower_id = :user_id"
    # Micropost.where("user_id IN (#{following_ids})
                    # OR user_id = :user_id", user_id: id)
    # V5 (p780) => :w
    part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    Micropost.joins(user: :followers).where(part_of_feed, { id: id })
  end

  # Follows a user
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Converts email to all lower-case
    def downcase_email
      email.downcase! # self.email = email.downcase
    end

    # Create a main sample user
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
