module Moltrio
  module Config

    class EnvVariablesAdapter < Adapter
      def initialize(prefix)
        @prefix = prefix
      end

      def missing_namespace?
        false
      end

      def [](key)
        ENV[to_env_variable(key)]
      end

      def []=(key, value)
        ENV[to_env_variable(key)] = value
      end

      def has_key?(key)
        ENV.has_key?(to_env_variable(key))
      end

      def fetch(key, *args, &block)
        ENV.fetch(to_env_variable(key), *args, &block)
      end

    private
      attr_reader :prefix

      def to_env_variable(key)
        [prefix, key.gsub('.', '_')].join("_").upcase
      end
    end

  end
end
