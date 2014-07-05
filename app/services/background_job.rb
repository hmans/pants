module BackgroundJob
  def self.included(base)
    base.send :include, SuckerPunch::Job
  end

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end

  def initialize(*args)
    @time_created = Time.now
    super
  end

  def with_appsignal(method = 'perform', &blk)
    Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

    ActiveSupport::Notifications.instrument('perform_job.sucker_punch',
      :class => self.class.to_s,
      :method => method,
      :queue_time => (Time.now - @time_created).to_f
    ) do
      yield
    end
  rescue Exception => exception
    unless Appsignal.is_ignored_exception?(exception)
      Appsignal::Transaction.current.add_exception(exception)
    end
    raise exception
  ensure
    Appsignal::Transaction.current.complete!
  end
end
