Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update]
      get "/my-profile", to: 'users#my_profile'
      resources :tasks
      post '/login', to: 'users#user_login'
      post '/create_status', to: 'tasks#create_status'
    end
  end
end
