class UserPoller < Service
  def perform
    logger.info "UserPoller running..."

    users_to_poll.each do |user|
      logger.info "Polling #{user.domain}"

      begin
        UserFetcher.perform(user.url)
        user.poll!
      rescue StandardError => e
        logger.error "Error while polling #{user.domain}: #{e.message}"
      end
    end

    logger.info "UserPoller done."
  end

  private

  def users_to_poll
    User.can_be_polled.order('Random()').first(5)
  end
end
