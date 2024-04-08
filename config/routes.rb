Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update]
      get "/my-profile", to: 'users#my_profile'
      resources :tasks
      post '/login', to: 'users#user_login'
      post '/create_status', to: 'tasks#create_status'

      # get '/auth/auth0/callback' => 'auth0#callback'
      # get '/auth/failure' => 'auth0#failure'
      # get '/auth/logout' => 'auth0#logout'

      post 'auth/login', to: 'auth0#login'
      post 'auth/create_user', to: 'auth0#create_user'
    end
  end
end
