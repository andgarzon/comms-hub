Rails.application.routes.draw do
  get "whatsapp_audiences/index"
  get "whatsapp_audiences/new"
  get "whatsapp_audiences/create"
  get "whatsapp_audiences/edit"
  get "whatsapp_audiences/update"
  get "whatsapp_audiences/destroy"
  get "email_audiences/index"
  get "email_audiences/new"
  get "email_audiences/create"
  get "email_audiences/edit"
  get "email_audiences/update"
  get "email_audiences/destroy"
  get "slack_audiences/index"
  get "slack_audiences/new"
  get "slack_audiences/create"
  get "slack_audiences/edit"
  get "slack_audiences/update"
  get "slack_audiences/destroy"
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
