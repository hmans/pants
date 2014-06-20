Rails.application.routes.draw do
  # Resources
  resources :posts

  # Plain routes
  match 'login' => 'auth#login', via: [:get, :post]
  root to: 'posts#index'
end
