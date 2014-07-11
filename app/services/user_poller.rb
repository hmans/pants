class UserPoller
  include Backgroundable

  def poll!
    Rails.logger.info "UserPoller running..."

    users_to_poll.each do |user|
      Rails.logger.info "Polling #{user.domain}"

      begin
        UserFetcher.new(user.url).fetch!
        user.poll!
      rescue StandardError => e
        Rails.logger.error "Error while polling #{user.domain}: #{e.message}"
      end
    end

    Rails.logger.info "UserPoller done."
  end

  private

  def users_to_poll
    User.can_be_polled.order('Random()').first(5)
  end
end
