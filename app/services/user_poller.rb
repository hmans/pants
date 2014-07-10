class UserPoller
  include BackgroundJob
  include FistOfFury::Recurrent

  def perform
    with_appsignal do
      with_database do
        Rails.logger.info "UserPoller running..."

        users_to_poll.each do |user|
          Rails.logger.info "Polling #{user.domain}"

          begin
            UserFetcher.perform(user.url)
            user.poll!
          rescue StandardError => e
            Rails.logger.error "Error while polling #{user.domain}: #{e.message}"
          end
        end

        Rails.logger.info "UserPoller done."
      end
    end
  end

  private

  def users_to_poll
    User.can_be_polled.order('Random()').first(5)
  end
end
