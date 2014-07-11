class Server::PingsController < ServerController
  load_and_authorize_resource :ping

  def index
    @pings = @pings.where('created_at > ?', 24.hours.ago).order('created_at DESC')
    respond_with @pings
  end
end
