Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Explicit route for the status endpoint
  get "/status" => "status#index"

  # Map the root URL ("/") to the custom StatusController
  root to: "status#index"

  resources :post_tests, only: [ :index, :create ]
  post "/post_test/real" => "post_tests#real_post"

  get "/weather" => "weathers#city"
end
