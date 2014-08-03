class BatchUserPoller < Service
  def perform
    domains = domains_to_poll
    logger.info "About to poll the following domains: #{domains.to_sentence}"

    domains.each do |domain|
      UserPoller.perform(domain)
    end
  end

  private

  def domains_to_poll
    User.remote
      .joins(:followings)
      .where("last_polled_at IS NULL OR last_polled_at < ?", 15.minutes.ago)
      .limit(10)
      .uniq
      .pluck(:domain)
  end
end
