module BackgroundJob
  def self.included(base)
    base.send :include, SuckerPunch::Job
  end

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end
end
