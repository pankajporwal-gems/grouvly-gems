Rails.application.routes.draw do
  root 'pages#index', via: [:get, :post]

  # match '/auth/admin/callback', to: 'sessions#authenticate_admin', as: :google_callback, via: [:get, :post]
  # match 'auth/facebook/callback', to: 'sessions#create', as: :facebook_callback, via: [:get, :post]
  match 'auth/failure', to: redirect('/why-facebook'), as: :facebook_failure, via: [:get, :post]
  match 'logout', to: 'sessions#destroy', via: [:get, :post]
  match 'about-us', to: 'pages#about_us', via: :get
  match 'bars-and-venues', to: 'pages#bars_and_venues', via: [:get, :post]
  match 'contact-us', to: 'pages#contact_us', via: [:get, :post]
  match 'faq', to: 'pages#faq', via: :get
  match 'how-it-works', to: 'pages#how_it_works', via: :get
  match 'press', to: 'pages#press', via: :get
  match 'privacy-policy', to: 'pages#privacy_policy', via: :get
  match 'terms-of-service', to: 'pages#terms_of_service', via: :get
  match 'why-facebook', to: 'pages#why_facebook', via: :get
  match 'r/:id', to: 'user/reservations#join', as: :join_reservation, via: :get
  match 'c/:id', to: 'pages#join', as: :join_referral, via: :get
  match 'venue/confirm', to: 'venues#confirm_booking', as: :venue_confirm_booking, via: :get
  match 'venue/reject', to: 'venues#reject_booking', as: :venue_reject_booking, via: :get

  match 'facebookprivatepilot', to: redirect('/'), via: :get

  get '/login', to: 'sessions#new', as: :new_user_login
  post '/login', to: 'sessions#create', as: :user_login

  namespace :admin do
    root to: 'admins#dashboard'

    resources :applicants, only: [:index, :show] do
      collection do
        get 'accept_selected'
        get 'reject_selected'
        get 'export_applicant'
      end
      member do
        get 'accept'
        post 'accept_member'
        get 'reject'
        post 'reject_member'
        get 'block'
        post 'block_member'
      end
    end

    resources :pools, only:[:index, :show, :create] do
      member do
        get 'possible_matches'
      end
      collection do
        get 'new_grouvly'
        post 'book_grouvly'
        post 'update_reservation_date'
      end
    end

    resources :reservations do
      collection do
        post 'capture_all_payments'
        post 'refund_amount'
      end
      member do
        get 'cancel_booking'
      end
    end

    resources :members, only: [:index, :show, :edit,:update] do
      member do
        post 'create_note'
      end
      collection do
        get 'search'
      end
    end

    resources :matches, only: [:index, :show] do
      member do
        post 'unmatch'
        post 'confirm_match'
      end
      collection do
        post 'book_venues', to: 'matches#book_venues'
        post 'notify_location', to: 'matches#notify_venue_location_details'
      end
    end

    resources :venues
    resources :vouchers
  end

  namespace :user do
    root to: 'users#dashboard'

    resource :membership, only: [:new, :create, :edit, :update] do
      member do
        get 'finish'
        get 'invite'
        get 'apply'
        patch 'submit_application'
      end
    end

    resources :reservations, only: [:new, :create] do
      member do
        get 'invite_wings'
        get 'confirmed'
        get 'roll'
        get 'refund_amount'
      end
      collection do
        post 'roll_confirmed'
        get 'venue/confirm/:id', to: 'reservations#confirm_venue_notification', as: :confirm_location
      end
    end

    resource :payment, only: [:new, :create] do
      member do
        post 'validate_voucher'
      end
    end
  end

  get 'admin/login', to: 'sessions#new_admin'
  post 'admin/login', to: 'sessions#admin_login'

  scope :location, as: :location do
    get 'countries', to: 'locations#countries'
    get 'neighborhoods', to: 'locations#neighborhoods'
  end

  constraints subdomain: :blog do
    get "*all", to: redirect { |params, req| "https://grouvly.com/blog/#{params[:all]}" }
  end

  get '/blog' => redirect('https://www.grouvly.com/blog/')

  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end

  mount Sidekiq::Web, at: '/2kQ1VqsGzd'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
