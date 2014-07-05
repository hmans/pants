class UserPoller < BackgroundJob
  include FistOfFury::Recurrent

  def perform
    with_appsignal(self.class, :perform) do
      with_database do
        users_to_poll.each do |user|
          begin
            user.poll!
          rescue StandardError => e
            Rails.logger.error "Error while polling #{user.domain}: #{e.message}"
          end
        end
      end
    end
  end

  private

  def users_to_poll
    User.joins(:followings).can_be_polled.order('Random()').first(5)
  end
end
