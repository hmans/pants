module Backgroundable
  class BackgroundJob
    def initialize(opts = {})
      @opts = opts
      @time_created = Time.now
    end

    def run(*args, &blk)
      Thread.new do
        with_appsignal do
          with_database do
            with_transaction do
              yield if block_given?
            end
          end
        end
      end
    end

    def with_database(&blk)
      ActiveRecord::Base.connection_pool.with_connection(&blk)
    end

    def with_transaction(&blk)
      ActiveRecord::Base.transaction(&blk)
    end

    def with_appsignal(&blk)
      yield

      # if defined?(Appsignal) && Appsignal::Transaction.current.nil?
      #   begin
      #     Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

      #     ActiveSupport::Notifications.instrument('perform_job.backgroundable',
      #       :class      => (@opts[:klass] || self.class).to_s,
      #       :method     => (@opts[:method] || 'run').to_s,
      #       :queue_time => (Time.now - @time_created).to_f
      #     ) do
      #       yield
      #     end
      #   rescue Exception => exception
      #     unless Appsignal.is_ignored_exception?(exception)
      #       Appsignal::Transaction.current.add_exception(exception)
      #     end
      #     raise exception
      #   ensure
      #     Appsignal::Transaction.current.complete!
      #   end
      # else
      #   yield
      # end
    end
  end

  class BackgroundProxy
    def initialize(obj)
      @obj = obj
    end

    def method_missing(method, *args, &blk)
      if @obj.respond_to?(method)
        BackgroundJob.new(klass: @obj.class, method: method).run do
          @obj.send(method, *args, &blk)
        end
      else
        super
      end
    end
  end

  def async
    BackgroundProxy.new(self)
  end
end
