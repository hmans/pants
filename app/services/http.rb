# A simple wrapper around HTTParty with the single purpose of setting some
# default options. And doing some wrapping.
#
class HTTP
  include HTTParty

  # Don't verify SSL certificates. Probably a bad idea in the long run.
  default_options.update(verify: false)
end
