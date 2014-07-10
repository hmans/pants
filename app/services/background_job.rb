# A bit of custom "DSL" around SuckerPunch.
#
module BackgroundJob
  extend ActiveSupport::Concern

  included do
    include SuckerPunch::Job
  end

  def initialize(*args)
    @time_created = Time.now
    super
  end

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end

  def with_appsignal(&blk)
    if defined?(Appsignal) && Appsignal::Transaction.current.nil?
      begin
        Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

        ActiveSupport::Notifications.instrument('perform_job.sucker_punch',
          :class      => self.class.to_s,
          :method     => 'perform',
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
    else
      yield
    end
  end

  module ClassMethods
    def perform(*args)
      new.perform(*args)
    end

    def perform_async(*args)
      new.async.perform(*args)
    end
  end
end
