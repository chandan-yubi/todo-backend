class ApplicationController < ActionController::Base
    def authenticate_user
        token = request.headers['Authorization']
        decoded_token = JwtService.verify(token)
        #Return Expired if token is expired
        expiry = decoded_token[0]['exp']
        if Time.now.to_i > expiry
            render json: { error: 'Token Expired' }, status: :unauthorized
            return
        end
        @current_user = User.find_by(auth0_user_id: decoded_token[0]['sub'])
    rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
    end

    def current_user
        @current_user
    end
end
