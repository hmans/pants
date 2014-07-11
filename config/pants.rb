# This is the Pants configuration file.
#
Pants.configure do |config|
  config.server do |server|
    # Your server's tagline will be displayed in the footer of
    # every #pants site you're hosting. Use it to inform users
    # who's running the server, how they can contact you, and so on.
    #
    server.tagline "Hosting provided by <a href=\"http://pants.social\">pants.social</a>, the original #pants server.".html_safe
  end
end
