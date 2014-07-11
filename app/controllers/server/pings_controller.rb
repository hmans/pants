class Server::PingsController < ServerController
  load_and_authorize_resource :ping

  def index
    @pings = @pings.order('created_at DESC')
    respond_with @pings
  end
end
