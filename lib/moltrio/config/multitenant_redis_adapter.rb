require_relative 'adapter'

module Moltrio
  module Config
    class MultitenantRedisAdapter < Adapter
      def initialize(config, base_path)
        @config = config
        @base_path = base_path
      end

      def requires_namespace?
        true
      end

      def on_namespace(namespace)
        SingleRedisAdapter.new(config, [base_path, namespace].join("."))
      end
    end
  end
end
