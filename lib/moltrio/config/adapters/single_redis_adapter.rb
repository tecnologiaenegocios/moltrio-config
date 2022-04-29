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
        redis.exists?(normalize_key(key))
      end

      def [](key)
        redis.get normalize_key(key)
      end

      def []=(key, value)
        redis.set(normalize_key(key), value)
      end

    private

      def redis
        @redis ||= @redis_builder.call
      end

      def normalize_key(key)
        [prefix, key].join(':')
      end
    end
  end
end
