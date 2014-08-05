# This is the Capistrano configuration file I'm using to deploy to http://pants.social/.
# It will likely not work out of the box for you. If you want to use Capistrano
# to deploy #pants, please modify this file first.
#
require 'dotenv'
Dotenv.load

# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'pants'
set :stages, ["production"]
set :repo_url, 'git@github.com:hmans/pants.git'
set :deploy_via, :remote_cache

# Default branch is :master
current_branch = proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
if current_branch != 'master'
  ask :branch, current_branch
end

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/pants'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env.production config/initializers/action_mailer.rb}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :chruby_ruby, '2.1'

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end
end
