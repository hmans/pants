class BackgroundJob
  include SuckerPunch::Job

  def initialize(*args)
    @time_created = Time.now
    super
  end

  def perform(obj, method, *args)
    with_appsignal(obj.class, method) do
      with_database do
        obj.send(method, *args)
      end
    end
  end

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end

  def with_appsignal(klass, method, &blk)
    Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

    ActiveSupport::Notifications.instrument('perform_job.sucker_punch',
      :class      => klass.to_s,
      :method     => method.to_s,
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

  class << self
    def sync(*args)
      new.perform(*args)
    end

    def async(*args)
      new.async.perform(*args)
    end
  end
end
