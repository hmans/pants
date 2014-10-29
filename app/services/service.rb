class Service
  class ServiceLogger < Logger
    attr_accessor :klass

    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{klass.to_s} #{msg}\n"
    end
  end

  def perform(*args)
    raise "not implemented"
  end

  def logger
    self.class.logger
  end

  def perform!(*args)
    with_database do
      with_exception_notifications(*args) do
        with_network_failure_handling do
          with_transaction do
            perform(*args)
          end
        end
      end
    end
  end

  def perform_async(*args)
    perform_sync(*args)
  end

  def with_network_failure_handling
    yield
  rescue SocketError, OpenSSL::SSL::SSLError => e
    logger.error "NETWORK FAILURE: #{e}"
  end

  def with_exception_notifications(*original_args, &blk)
    original_args = original_args.dup
    r = yield
    logger.info "SUCCESS"
    r
  rescue => e
    logger.error "FAILED: #{e}"

    # Collect some extra data to report in exception notification
    data = {
      :class => self.class.to_s,
      :args => original_args
    }

    # Send exception notification
    ExceptionNotifier.notify_exception(e, data: data)

    # Re-raise exception in development
    raise if Rails.env.development?

    # Done with this grim task.
    nil
  end

  def with_transaction(&blk)
    ActiveRecord::Base.transaction(&blk)
  end

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end

  class << self
    def perform(*args)
      logger.info "START: #{args}"
      new.perform!(*args)
    end

    def perform_async(*args)
      Thread.new do
        perform(*args)
      end
    end

    alias_method :async, :perform_async

    def logger
      @logger ||= begin
        log = File.open("#{Rails.root}/log/services.log", 'a')
        log.sync = true
        logger = ServiceLogger.new(log)
        logger.klass = self
        logger
      end
    end
  end
end
