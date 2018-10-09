Rails.application.routes.draw do
  root 'application#landing_page'
  get 'my_profile', to: 'customers#my_profile'
  get 'my_orders', to: 'customers#my_orders'
  get 'customer_orders', to: 'orders#customer_orders'
  get 'results', to: 'matches#results'
  get 'admins_root', to: 'application#home'
  get 'checkin/new', to: 'checkins#new'
  post 'check_in', to: 'checkins#check_in'
  post 'check_qr_code', to: 'checkins#check_qr_code'

  devise_for :admins,
  path: '/admin',
  controllers: {
    sessions: 'admins/sessions',
    passwords: 'admins/passwords',
    registrations: 'admins/registrations'
  }, path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    edit: '',
    registration: 'profile'
  }
  devise_for :customers, controllers: { omniauth_callbacks: 'customers/omniauth_callbacks' }

  devise_scope :customer do
    get 'customer_sign_in', to: 'customers/sessions#new', as: :new_customer_session
    delete 'customer_sign_out', to: 'customers/sessions#destroy', as: :destroy_customer_session
  end

  resources :admins

  resources :promotions do
    collection do
      get 'find/:code', to: 'promotions#find'
    end
  end

  resources :teams do
    member do
      get :home_stadium
    end
    get :ticket_types, to: 'ticket_types#season'
  end
  
  resources :stadiums do
    resources :zones
  end
  
  resources :matches do
    resources :ticket_types
  end

  resources :customers
  
  resources :seasons do
    collection do
      get :total_price, to: 'seasons#total_price'
    end
    get :season_time, to: 'seasons#generate_data'
  end

  resources :orders do
    member do
      get :logs
      get :show_qr_codes
    end

    collection do
      get :new_season_order, as: :new_season
      post 'create_customer_order', to: 'orders#create_customer_order'
    end
  end

  match 'request_purchase', to: 'payments#request_purchase', via: [:get, :post]
  get 'complete_purchase', to: 'payments#complete_purchase'

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
end
