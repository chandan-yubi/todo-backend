class ApplicationController < ActionController::Base
    def authenticate_user
        token = request.headers['Authorization']&.split&.last
        decoded_token = JwtService.decode(token)
        @current_user = User.find(decoded_token[:user_id])
    rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
    end

    def current_user
        @current_user
    end
end
