Rails.application.routes.draw do
  get "admins/new"
  get "admins/create"
  get "dashboard/index"
  get "sessions/new"
  get "sessions/send_otp"
  get "sessions/verify"
  get "sessions/confirm_otp"
  get "feedback_details/new"
  get "feedback_details/create"
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "sessions#new"

  # Sessions routes
  get  '/login', to: 'sessions#new'
  post '/send_otp', to: 'sessions#send_otp'
  get  '/verify_otp', to: 'sessions#verify_otp'
  post '/confirm_otp', to: 'sessions#confirm_otp'
  get '/resend_otp', to: 'sessions#resend_otp'
  delete '/logout', to: 'sessions#destroy'

  # Dashboard routes
  get "admin/dashboard", to: "dashboard#index"
  get "export_csv", to: "dashboard#export_csv"
  patch 'admin/:id/resolve', to: 'dashboard#resolve', as: 'resolve_feedback'

  # Feedback routes
  resources :feedback_details, only: [:new, :create]
  post '/import_csv', to: 'feedback_details#import_csv'
  get 'thank_you', to: 'feedback_details#thank_you', as: :thank_you

  # Admin login routes
  get 'admin/login', to: 'admins#login'
  post 'admin/login', to: 'admins#login_create'
  delete 'admin/logout', to: 'admins#logout'

  # Admin Sign up routes
  get 'admin/signup', to: 'admins#new'
  post 'admin/signup', to: 'admins#create'


end
