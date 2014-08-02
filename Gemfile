source 'https://rubygems.org'

# Make sure we're running on Ruby 2.1
ruby '2.1.2'

# Core
gem 'rails', '4.1.4'
gem 'pg'
gem 'quiet_assets'
gem 'puma'
gem 'rack-cache', :require => 'rack/cache'
gem 'timers'
gem 'exception_notification'

# Frontend
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'slim-rails'
gem 'compass-rails'
gem 'simple_form'
gem 'slodown', github: 'hmans/slodown'
gem 'font-awesome-rails'
gem 'kaminari'
gem 'microformats2'
gem 'dotenv'
gem 'dotenv-rails'
gem 'dotenv-deployment'

# Binary asset handling
gem 'dragonfly'
gem 'dragonfly-s3_data_store'

# Authorization/Authentication
gem 'cancancan'
gem 'bcrypt', '~> 3.1.7'

# API
gem 'jbuilder', '~> 2.0'

# HTTP interactions
gem 'httparty'
gem 'webmention', github: 'indieweb/mention-client-ruby'

# Development & Testing only
#
group :test, :development do
  # Spring application reloader
  gem 'spring'
  gem "spring-commands-rspec"

  # Debugging
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'

  # RSpec & friends
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
end

# Development only.
group :development do
end

# Testing only.
#
group :test do
  gem 'webmock'
end

# Production only
#
group :production do
end

group :tools do
  gem 'terminal-notifier'

  # Capistrano
  gem 'capistrano-rails'
  gem 'capistrano-chruby'
  gem 'capistrano-bundler'
end
