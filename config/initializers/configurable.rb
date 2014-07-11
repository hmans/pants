module Configurable
  class ConfigurationProxy
    attr_reader :data

    def initialize
      @data = {}
    end

    def method_missing(method, *args, &blk)
      if args.any? || block_given?
        if block_given?
          @data[method] = self.class.parse(&blk)
        else
          @data[method] = args.first
        end
      else
        @data[method]
      end
    end

    class << self
      def parse(&blk)
        new.tap do |instance|
          blk.call(instance)
        end
      end
    end
  end

  def config
    @config
  end

  def configure(&blk)
    @config = ConfigurationProxy.parse(&blk)
  end
end

module Pants
  extend Configurable
end

require File.join(Rails.root, 'config/pants.rb')
