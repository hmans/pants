require 'dragonfly'

class PostgresDataStore
  # Store the data AND meta, and return a unique string uid
  def write(content, opts={})
    data_oid = store_lo(content.data)
    meta_oid = store_lo(Marshal.dump(content.meta))
    "#{data_oid}/#{meta_oid}"
  end

  # Retrieve the data and meta as a 2-item array
  def read(uid)
    data_oid, meta_oid = uid.split('/')
    data = fetch_lo(data_oid)
    meta = Marshal.load(fetch_lo(meta_oid))

    data && [data, meta]
  end

  def destroy(uid)
    data_oid, meta_oid = uid.split('/')
    remove_lo(data_oid)
    remove_lo(meta_oid)
  end

private

  def store_lo(data)
    ActiveRecord::Base.transaction do
      identifier = connection.lo_creat
      lo = connection.lo_open(identifier, ::PG::INV_WRITE)
      connection.lo_truncate(lo, 0)
      connection.lo_write(lo, data)
      connection.lo_close(lo)
      return identifier
    end
  end

  def fetch_lo(identifier)
    ActiveRecord::Base.transaction do
      lo = connection.lo_open(identifier.to_i)
      size = connection.lo_lseek(lo, 0, 2)
      connection.lo_lseek(lo, 0, 0)
      content = connection.lo_read(lo, size)
      connection.lo_close(lo)
      return content
    end
  end

  def remove_lo(identifier)
    ActiveRecord::Base.transaction do
      connection.lo_unlink(identifier.to_i)
    end
  end

  def connection
    ActiveRecord::Base.connection.raw_connection
  end
end

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  protect_from_dos_attacks true
  secret Rails.application.secrets.dragonfly_secret

  url_format "/media/:job/:name"

  # datastore :file,
  #   root_path: Rails.root.join('public/system/dragonfly', Rails.env),
  #   server_root: Rails.root.join('public')

  datastore PostgresDataStore.new
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
