Rails.application.routes.draw do
  devise_for :customers
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  defaults format: :json do
    resources :stripe_webhooks, only: [:create]
  end
end
