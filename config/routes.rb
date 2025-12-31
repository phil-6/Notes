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
  end

  # Preferences
  patch "preferences", to: "preferences#update"

  # Root
  root "notes#index"
end
