Rails.application.routes.draw do
  # Login page
  match 'login' => 'auth#login', via: [:get, :post]

  # Ping
  post 'ping' => 'pings#create'

  # User
  resource :user, only: [:show, :edit, :update]

  # Friendships
  resources :friendships, path: 'friends'

  # Timeline
  get 'timeline(/:mode)' => 'timeline_entries#index', as: :timeline, mode: /all|incoming|friends/

  # Tag pages
  get 'tag/:tag' => 'posts#tagged', as: :tagged_posts
  get 'tag/all/:tag' => 'posts#tagged', as: :all_tagged_posts, all: 1

  # Daily archives
  get ':year-:month-:day' => 'posts#day', as: :day

  # Legacy
  get '/posts/:id' => 'posts#show'

  # Primary posts resource
  resources :posts, only: [:index, :create]
  resources :posts, path: '', except: [:index, :create]

  # /
  root to: 'posts#index'
end
