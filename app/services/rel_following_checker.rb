class RelFollowingChecker < Service
  def perform(url, opts = {})
    response = opts[:response] || HTTParty.get(url)

    if response.success?
      mf2 = Microformats2.parse(response.body).to_hash

      if mf2.has_key?(:rels) && (following = mf2[:rels]['following'])
        following.each do |f|
          domain = URI.parse(f).host

          # If we have a local user matching the domain, add the remote user
          # as a follower.
          if user = User.hosted.find_by(domain: domain)
            logger.info "Found rel-following for local user #{domain}"

            # Fetch user and mark as follower
            if follower ||= UserFetcher.perform(URI.join(url, '/').to_s)
              follower.add_friend(user)
            end
          end
        end
      end
    end
  end
end
