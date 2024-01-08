module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:create, :update, :user_login]
      before_action :authenticate_user, only: [:my_profile]
      def index
        users = User.all
        render json: {users: users}, status: :ok
      end

      def show
        user = User.find(params[:id])
        render json: user, status: :ok
      end

      def my_profile
        render json: current_user, status: :ok
      end

      def create
        user = User.new(user_params)
        user.password = user.password_digest
        if user.save
          # render json: {user: user}, status: :created
          payload = {
            user_id: user.id,
            email: user.email
          }
          token = JwtService.encode(payload)
          render json: {user: user, token: token}, status: :ok
        else
          render json: {errors: user.errors}, status: :unprocessable_entity
        end
      end

      def user_login
        login_credentials = login_params
        email = login_credentials[:email]
        password = login_credentials[:password_digest]
        user = User.find_by(email: email)
        unless user
          render json: {error: 'User Not Found. Please check credentials'}, status: :not_found
          return
        end

        unless user.authenticate(password)
          render json: { error: 'Invalid password' }, status: :unauthorized
          return
        end

        payload = {
          user_id: user.id,
          email: user.email
        }
        token = JwtService.encode(payload)
        render json: {user: user, token: token}, status: :ok
      end

      private
      def user_params
        params.require(:user).permit(:name, :email, :password_digest, :profileUrl)
      end

      def login_params
        params.require(:user).permit(:email, :password_digest)
      end
    end
  end
end