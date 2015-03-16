require_relative 'adapter'

module Moltrio
  module Config
    class SingleRedisAdapter < Adapter
      def initialize(config, namespace)
        @redis_builder = config.fetch(:redis)
        @namespace = namespace
      end

      def requires_namespace?
        false
      end

      def has_key?(key)
        storage.keys(key).count == 1
      end

    private

      def storage
        @redis_builder.call
      end
    end
  end
end
