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

    def self.auth0_decode(token)
        JWT.decode(token, Rails.application.config.auth0['auth0_client_secret'], true, algorithm: 'HS256').first
    end

    def self.verify(token)
        JWT.decode(token, nil,
                   true, # Verify the signature of this token
                   algorithm: 'RS256',
                   iss: "https://#{Rails.application.config.auth0['auth0_domain']}/",
                   verify_iss: true,
                   exp_leeway: 315569520,
                   aud: Rails.application.config.auth0['auth0_audience'],
                   verify_aud: true) do |header|
                    jwks_hash[header['kid']]
        end
    end
    
end