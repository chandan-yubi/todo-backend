class User < ApplicationRecord
    has_secure_password
    has_many :tasks, dependent: :destroy
    has_one :timeline
  
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    validates :password, presence: true, length: { minimum: 6 }

    def generate_jwt
        JwtService.encode({ user_id: id })
    end
end
  
