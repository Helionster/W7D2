class User < ApplicationRecord
    before_validation :ensure_session_token

    def generate_unique_session_token
        loop do
            token = SecureRandom::urlsafe_base64
            return token if !User.find_by(session_token: token)
        end
    end

    def reset_session_token!
        self.session_token = generate_unique_session_token
        self.save!
        self.session_token
    end

    def ensure_session_token
        self.session_token ||= generate_unique_session_token
    end

    def password=(password)
        self.password_digest = BCyrpt::Password.create(password)
        @password = password
    end

    def self.find_by_credentials(email,password)
        @user = User.find_by(email: email)

        if @user && user.is_password?(password)
            user 
        else  
            nil 
        end
    end

    def is_password?(password)
        po = BCyrpt::Password.new(self.password_digest)
        po.is_password?(password)
    end
end
