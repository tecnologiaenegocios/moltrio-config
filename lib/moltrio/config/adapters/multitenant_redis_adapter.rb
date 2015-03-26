require_relative 'adapter'

module Moltrio
  module Config
    class MultitenantRedisAdapter < Adapter
      def initialize(config, base_path)
        @config = config
        @base_path = base_path
      end

      def missing_namespace?
        true
      end

      def available_namespaces
        redis.smembers(base_path)
      end

      attr_reader :config, :base_path
      def on_namespace(namespace)
        SingleRedisAdapter.new(config, [base_path, namespace].join(":"))
      end

    private

      def redis
        @redis ||= @config.fetch(:redis).call
      end
    end
  end
end
