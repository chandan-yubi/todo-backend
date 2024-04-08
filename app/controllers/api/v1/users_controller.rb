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
        user.password = params[:password_digest]
        begin
          ActiveRecord::Base.transaction do
            if user.save
              create_response = Auth0Service.create_user(params[:email], params[:password_digest])
              user.update(auth0_user_id: create_response[:user_id])
              render json: { user: user, access_token: create_response[:access_token] }, status: :created
            end
          end
        rescue
          render json: { error: 'User Not Created' }, status: :unprocessable_entity
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
        login_response = Auth0Service.login_user(email, password)

        render json: {user: user, access_token: login_response["access_token"]}, status: :ok
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