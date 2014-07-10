# Ensure the jobs run only in a web server.
if defined?(Rails::Server) && Rails.env.production?
  Rails.logger.info "Firing up FistOfFury"
  FistOfFury.attack!
end

# Make this thing work in Passenger, too.
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Rails.logger.info "Firing up FistOfFury in new Passenger worker process"
    FistOfFury.attack!
  end
end
