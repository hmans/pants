if true #Rails.env.production?
  def fire_up_those_scheduled_tasks!
    Rails.logger.info "Firing up scheduled tasks..."

    Thread.new do
      timers = Timers.new
      timers.every(3.minutes) { UserPoller.new.poll! }
      loop { timers.wait }
    end
  end

  # Ensure the jobs run only in a web server.
  if defined?(Rails::Server)
    fire_up_those_scheduled_tasks!
  end

  # Make this thing work in Passenger, too.
  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      fire_up_those_scheduled_tasks!
    end
  end
end
