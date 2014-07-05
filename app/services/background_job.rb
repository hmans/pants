module BackgroundJob
  include SuckerPunch::Job

  def with_database(&blk)
    ActiveRecord::Base.connection_pool.with_connection(&blk)
  end
end
