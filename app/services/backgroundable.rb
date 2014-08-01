module Backgroundable
  class BackgroundJob
    def initialize(opts = {})
      @opts = opts
      @time_created = Time.now
    end

    def run(*args, &blk)
      Thread.new do
        with_exception_notifications do
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

    def with_exception_notifications(&blk)
      yield
    rescue => e
      ExceptionNotifier.notify_exception(e, data: {
        :class      => (@opts[:klass] || self.class).to_s,
        :method     => (@opts[:method] || 'run').to_s,
        :queue_time => (Time.now - @time_created).to_f
      })
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
