Rails.application.routes.draw do
  devise_for :users

  root "announcements#index"

  resources :announcements, only: [:index, :new, :create, :show] do
    member do
      patch :schedule
      patch :cancel_schedule
      patch :send_now
    end
  end

  resources :slack_audiences
  resources :email_audiences
  resources :whatsapp_audiences
  resources :audiences
end
