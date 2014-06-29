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
  get 'timeline' => 'timeline_entries#index'
  get 'timeline/all' => 'timeline_entries#index', all: true

  # Tag pages
  get 'tag/:tag' => 'posts#index', as: :tagged_posts

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
