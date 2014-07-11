Rails.application.routes.draw do
  # Login page
  match 'login' => 'auth#login', via: [:get, :post]
  delete 'login' => 'auth#logout'

  # Ping
  post 'ping' => 'pings#create'

  # User
  resource :user, only: [:show, :edit, :update]
  get 'user-flair' => 'users#flair', format: 'jpg'

  # Friendships
  resources :friendships, path: 'friends'

  # Timeline
  get 'network' => 'timeline_entries#index', as: :network
  delete 'network/incoming' => 'timeline_entries#hide_all_incoming'
  delete 'network/:id' => 'timeline_entries#destroy', as: :timeline_entry
  get 'network/incoming' => 'timeline_entries#incoming', as: :incoming_network

  # Tag pages
  get 'tag/:tag' => 'posts#tagged', as: :tagged_posts
  get 'tag/all/:tag' => 'posts#tagged', as: :all_tagged_posts, all: 1

  # Daily archives
  get ':year/:month/:day' => 'posts#day', as: :day,
    constraints: { year: /\d+/, month: /\d+/, day: /\d+/ }

  # Server Administration
  get 'server' => 'server#dashboard'
  namespace :server do
    resources :users
    resources :pings
  end

  # Legacy
  get '/posts/:id' => 'posts#show'
  get ':year-:month-:day' => redirect("/%{year}/%{month}/%{day}")
  get '/timeline' => redirect("/network")
  get '/timeline/incoming' => redirect("/network/incoming")
  get '/timeline/all' => redirect("/network/incoming")

  # Primary posts resource
  resources :posts, only: [:index, :create]
  resources :posts, path: '', except: [:index, :create]

  # /
  root to: 'posts#index'

  # catch-all route for 404s
  match '*splat', to: 'application#render_404', via: [:get, :post, :delete, :put], format: [:html]
end
