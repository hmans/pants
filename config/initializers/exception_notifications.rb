# This will enable exception notifications to be mailed to you. Please
# don't forget to also configure ActionMailer.
#
# if Rails.env.production? && ENV['EXCEPTION_NOTIFICATION_SENDER'].present?
#   Rails.application.config.middleware.use ExceptionNotification::Rack,
#     :email => {
#       :email_prefix => "[#pants] ",
#       :sender_address => ENV['EXCEPTION_NOTIFICATION_SENDER'],
#       :exception_recipients => ENV['EXCEPTION_NOTIFICATION_RECIPIENTS'].split.compact
#     }
# end
