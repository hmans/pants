if Rails.env.production?
  def fire_up_those_scheduled_tasks!
    Rails.logger.info "Firing up scheduled tasks..."

    Thread.new do
      timers = Timers::Group.new
      timers.every(1.minute) { BatchUserPoller.perform }
      loop { timers.wait }
    end
  end

  # Ensure the jobs run only in a web server.
  if defined?(Rack::Server)
    fire_up_those_scheduled_tasks!

  # Make this thing work in Passenger, too.
  elsif defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      fire_up_those_scheduled_tasks!
    end
  end
end
