source 'https://rubygems.org'

# Core
gem 'rails', '4.1.2'
gem 'pg'
gem 'quiet_assets'
gem 'httparty'
gem 'sucker_punch'
gem 'puma'

# Frontend
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
# gem 'therubyracer',  platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'slim-rails'
gem 'compass-rails'
gem 'simple_form'
gem 'slodown', github: 'hmans/slodown'
gem 'dragonfly'
gem 'dragonfly-s3_data_store'

# Authorization/Authentication
gem 'cancancan'
gem 'bcrypt', '~> 3.1.7'

# API
gem 'jbuilder', '~> 2.0'

# Development
group :test, :development do
  gem 'spring'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'dotenv-rails'
end

# Production only
group :production do
  gem 'dotenv-deployment'
end

# Gems that should be installed, but will not be required automatically.
group :tools do
  gem 'invoker'
  gem 'terminal-notifier'

  # Capistrano
  gem 'capistrano-rails'
  gem 'capistrano-chruby'
  gem 'capistrano-bundler'
end

# Use unicorn as the app server
# gem 'unicorn'
