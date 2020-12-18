Rails.application.routes.draw do
  devise_for :customer
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  authenticate :customer do
    namespace :customer do
      resources :profile
      resources :payment_allocations, only: %i[index create]
    end
  end
  defaults format: :json do
    resources :stripe_webhooks, only: [:create]
  end
end
