module ScheduledTasks
  @mutex = Mutex.new

  extend self

  def thread_running?
    @thread && @thread.alive?
  end

  def keepalive!
    return if thread_running?

    @mutex.synchronize do
      return if thread_running?
      start_worker!
    end
  end

  def start_worker!
    logger.info "Starting worker thread for scheduled tasks."

    @thread = Thread.new do
      timers = Timers::Group.new

      # Actual tasks to perform. Yay! We're randomizing times a bit because in
      # multi-process environments, we'll get more than one of these threads
      # running at the same time, and this is a cheap way to keep stuff
      # out of sync. I like pie.
      #
      timers.every(rand(50..70).seconds) { BatchUserPoller.perform }
      timers.every(rand(50..70).seconds) { FriendshipChecker.perform }

      loop { timers.wait }
    end
  end

  def logger
    Rails.logger
  end
end
