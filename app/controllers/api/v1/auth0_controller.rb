module Api
    module V1
        # ./app/controllers/auth0_controller.rb
        class Auth0Controller < ApplicationController
            skip_before_action :verify_authenticity_token

            def login
                auth0_params = {
                  client_id: Rails.application.config.auth0['auth0_client_id'],
                  client_secret: Rails.application.config.auth0['auth0_client_secret'],
                  audience: Rails.application.config.auth0['auth0_audience'],
                  grant_type: 'password',
                  username: params[:username], 
                  password: params[:password],
                  connection: 'Username-Password-Authentication',
                  scope: 'openid profile email'
                }
              
                response = HTTP.post("https://#{Rails.application.config.auth0['auth0_domain']}/oauth/token", form: auth0_params)
                dec = JwtService.verify(JSON.parse(response)["access_token"])
                byebug
                if response.status.ok?
                  render json: response.parse
                else
                  render json: { error: 'Authentication failed', details: response.parse }, status: :unauthorized
                end
              end
              

            def create_user
                user_params = {
                  email: params[:email], # Replace with the actual parameter name for email
                  password: params[:password], # Replace with the actual parameter name for password
                  connection: 'Username-Password-Authentication' # Replace with your database connection name
                }
              
                auth0_domain = Rails.application.config.auth0['auth0_domain']
              
                response = HTTP.post("https://#{auth0_domain}/dbconnections/signup", json: user_params)
                if response.status.ok?
                  login_params = {
                    email: params[:email], # Use the same email used for signup
                    password: params[:password], # Use the same password used for signup
                  }
                  byebug

                  login_response = login_user(login_params)
                  auth0_user_id = JwtService.verify(login_response["access_token"])[0]['sub']
                  render json: { user_id: auth0_user_id, access_token: login_response["access_token"],  }
                else
                  render json: { error: 'User creation failed', details: response.parse }, status: :unprocessable_entity
                end
            end
            def login_user(login_params)
                auth0_params = {
                  client_id: Rails.application.config.auth0['auth0_client_id'],
                  client_secret: Rails.application.config.auth0['auth0_client_secret'],
                  audience: Rails.application.config.auth0['auth0_audience'],
                  grant_type: 'password',
                  username: login_params[:email],
                  password: login_params[:password],
                  connection: 'Username-Password-Authentication',
                  scope: 'openid profile email'
                }
              
                login_response = HTTP.post("https://#{Rails.application.config.auth0['auth0_domain']}/oauth/token", form: auth0_params)
                return JSON.parse(login_response)
            end
              
        end
    end
end