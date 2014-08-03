if Rails.env.production?
  def fire_up_those_scheduled_tasks!
    Rails.logger.info "Firing up scheduled tasks..."

    Thread.new do
      timers = Timers::Group.new
      timers.every(1.minute) { BatchUserPoller.perform }
      loop { timers.wait }
    end
  end

  # First of all, look for Passenger
  if defined?(PhusionPassenger)
    Rails.logger.info "Passenger detected."
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      fire_up_those_scheduled_tasks!
    end

  # Check for Rack::Server (we don't want these running in our console.)
  elsif defined?(Rack::Server)
    Rails.logger.info "Rack::Server detected."
    fire_up_those_scheduled_tasks!

  # When we get here, we couldn't start up the background task. Shit!
  elsif
    Rails.logger.error "Failed to start scheduler thread. Polling disabled."
  end
end
