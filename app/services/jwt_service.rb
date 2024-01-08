class JwtService
    SECRET_KEY = Rails.application.credentials.secret_key_base

    def self.encode(payload, exp = 5.days.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new decoded
    end

    def self.current_active_user
        header = request.headers['Authorization']
        unless header
            render json: { error: 'Not Authorized' }, status: :unauthorized
            return
        end
        token = header.split(' ').last
        decoded = decode(token)
        user = User.find(decoded[:user_id])
        return user
    end
end