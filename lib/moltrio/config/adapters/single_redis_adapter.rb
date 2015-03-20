require_relative 'adapter'

module Moltrio
  module Config
    class SingleRedisAdapter < Adapter
      attr_reader :prefix
      def initialize(config, prefix)
        @redis_builder = config.fetch(:redis)
        @prefix = prefix
      end

      def missing_namespace?
        false
      end

      def has_key?(key)
        redis.keys(normalize_key(key)).count == 1
      end

      def [](key)
        redis[normalize_key(key)]
      end

      def []=(key, value)
        redis[normalize_key(key)] = value
      end

    private

      def redis
        @redis ||= @redis_builder.call
      end

      def normalize_key(key)
        [prefix, key].join('.')
      end
    end
  end
end
