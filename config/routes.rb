Rails.application.routes.draw do
  devise_for :customer, controllers: {
    registrations: 'customers/registrations'
  },
  skip: [:registrations]

  as :customer do
    get "customer/sign_up", to: "customers/registrations#new", as: :new_customer_registration
    post "customer/sign_up", to: "customers/registrations#create", as: :customer_registration
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  authenticate :customer do
    namespace :customer do
      resources :profile, only: %i[index update]
      resources :payment_allocations, only: %i[create]
    end
  end
  resources :customer do
    resources :avatar, module: :customer, only: %i[index], format: :svg
  end
  defaults format: :json do
    resources :stripe_webhooks, only: [:create]
  end
end
