Rails.application.routes.draw do
  devise_for :users

  root "announcements#index"

  resources :announcements, only: [ :index, :new, :create, :show ] do
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
  resources :users, path: "manage/users", as: :manage_users
  resources :settings, only: [ :index ]
  resources :help, only: [ :index ]

  # Integration routes
  get "integrations", to: "integrations#index", as: :integrations
  get "integrations/openai", to: "integrations#openai", as: :openai_integration
  patch "integrations/openai", to: "integrations#update_openai"
  post "integrations/openai/test", to: "integrations#test_openai", as: :test_openai_integration
  get "integrations/whatsapp", to: "integrations#whatsapp", as: :whatsapp_integration
  patch "integrations/whatsapp", to: "integrations#update_whatsapp"
  post "integrations/whatsapp/test", to: "integrations#test_whatsapp", as: :test_whatsapp_integration
  get "integrations/slack", to: "integrations#slack", as: :slack_integration
  patch "integrations/slack", to: "integrations#update_slack"
  post "integrations/slack/test", to: "integrations#test_slack", as: :test_slack_integration
  get "integrations/email", to: "integrations#email", as: :email_integration
  patch "integrations/email", to: "integrations#update_email"
end
