Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used for load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root route
  root "sessions#new"

  # Authentication routes
  resource :session, only: %i[new create edit update destroy]

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Profile
  resource :profile, only: %i[show edit update]

  # Events
  resources :events, only: %i[index new create show edit update destroy] do
    member do
      post :join
      post :leave
    end

    # Projects nested under events
    resources :projects, only: %i[create destroy] do
      member do
        # Vote for a project (create/remove own vote)
        post :vote, to: "votes#create"
        delete :vote, to: "votes#destroy"
      end
    end

    # Admin vote management (revoke any user's vote)
    namespace :admin, module: :events do
      resources :votes, only: %i[destroy] do
        member do
          post :revoke
        end
      end
    end
  end
end
