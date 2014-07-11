module Backgroundable
  class BackgroundJob
    def initialize
      @time_created = Time.now
    end

    def run(*args, &blk)
      Thread.new do
        with_appsignal do
          with_database do
            yield if block_given?
          end
        end
      end
    end

    def with_database(&blk)
      ActiveRecord::Base.connection_pool.with_connection(&blk)
    end

    def with_appsignal(&blk)
      if defined?(Appsignal) && Appsignal::Transaction.current.nil?
        begin
          Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

          ActiveSupport::Notifications.instrument('perform_job.backgroundable',
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

    class << self
      def run(*args, &blk)
        new.run(*args, &blk)
      end
    end
  end

  class BackgroundProxy
    def initialize(obj)
      @obj = obj
    end

    def method_missing(method, *args, &blk)
      BackgroundJob.run do
        @obj.send(method, *args, &blk)
      end
    end
  end

  def async
    BackgroundProxy.new(self)
  end
end
