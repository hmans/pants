# Ensure the jobs run only in a web server.
if defined?(Rails::Server) && Rails.env.production?
  FistOfFury.attack! do
    UserPoller.recurs { minutely }
  end
end
