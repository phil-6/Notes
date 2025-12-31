Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  # Notes
  resources :notes do
    member do
      patch :pin
      patch :unpin
    end
    resources :shared_notes, only: [ :create, :destroy ]
    resources :versions, controller: "note_versions", only: [ :index, :show ] do
      member do
        post :restore
      end
    end
  end

  # Shared Notes
  get "shared_with_me", to: "shared_notes#index", as: :shared_with_me

  # Connections
  resources :connections, only: [ :index, :create, :destroy ] do
    member do
      patch :accept
      patch :reject
    end
  end

  # Preferences
  patch "preferences", to: "preferences#update"

  # Root
  root "notes#index"
end
