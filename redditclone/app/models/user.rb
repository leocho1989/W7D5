class User < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :password, length: { minimum: 6, allow_nil: true}
    validates :password_digest, presence: true
    validates :session_token, presence: true, uniqueness: true

    attr_reader :password

    after_initialize :ensure_session_token

      has_many :subs,
    class_name: :Sub,
    foreign_key: :moderator_id,
    primary_key: :id,
    inverse_of: :moderator

  has_many :posts, inverse_of: :author
  has_many :comments, inverse_of: :author
  has_many :user_votes, inverse_of: :user

    def self.find_by_credentials(name, password)
        user = User.find_by(name: name)
        return nil if user.nil?
        user.is_password?(password) ? user : nil
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def reset_session_token!
        self.session_token = SecureRandom.base64(64)
        self.save!
        self.session_token
    end

    private
    
    def ensure_session_token
        self.session_token ||= SecureRandom.base64(64)
    end
        
end
