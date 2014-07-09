# Base class for all server admin controllers.
#
class ServerController < ApplicationController
  # Only allow admins.
  #
  before_filter do
    authorize! :manage, :server
  end

  def dashboard
  end
end
