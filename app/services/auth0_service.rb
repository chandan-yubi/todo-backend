class Auth0Service
    def self.login_user(email, password)
        auth0_params = {
          client_id: Rails.application.config.auth0['auth0_client_id'],
          client_secret: Rails.application.config.auth0['auth0_client_secret'],
          audience: Rails.application.config.auth0['auth0_audience'],
          grant_type: 'password',
          username: email,
          password: password,
          connection: 'Username-Password-Authentication',
          scope: 'openid profile email'
        }
        login_response = HTTP.post("https://#{Rails.application.config.auth0['auth0_domain']}/oauth/token", form: auth0_params)
        return JSON.parse(login_response)
    end

    def self.create_user(email, password)
        user_params = {
          email: email, # Replace with the actual parameter name for email
          password: password, # Replace with the actual parameter name for password
          connection: 'Username-Password-Authentication' # Replace with your database connection name
        }
      
        auth0_domain = Rails.application.config.auth0['auth0_domain']
      
        response = HTTP.post("https://#{auth0_domain}/dbconnections/signup", json: user_params)

        if response.status.ok?
            login_response = self.login_user(email, password)
            auth0_user_id = JwtService.verify(login_response["access_token"])[0]['sub']
            return { user_id: auth0_user_id, access_token: login_response["access_token"]}
        else
            return { error: 'User creation failed', details: response.parse }, status: :unprocessable_entity
        end
    end
end