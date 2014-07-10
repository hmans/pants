# Ensure the jobs run only in a web server.
if defined?(Rails::Server) && Rails.env.production?
  Rails.logger.info "Firing up FistOfFury"
  FistOfFury.attack!
end
