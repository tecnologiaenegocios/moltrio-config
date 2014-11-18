module Moltrio
  module Config

    class DatabaseYmlStorage < Storage
      attr_reader :real_storage, :environment

      def initialize(storage, environment: rails_environment)
        @real_storage = storage
        @environment = environment
      end

      def [](key)
        real_storage[transform_key(key)]
      end

      def []=(key, value)
        real_storage[transform_key(key)] = value
      end

      def has_key?(key)
        real_storage.has_key?(transform_key(key))
      end

    private

      def transform_key(key)
        key.sub(/^database_yml/, environment)
      end

      def rails_environment
        if defined?(RAILS_ENV)
          RAILS_ENV
        else
          "production"
        end
      end
    end

  end
end
