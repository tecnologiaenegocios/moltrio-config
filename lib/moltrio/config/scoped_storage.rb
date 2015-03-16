require_relative "storage"

module Moltrio
  module Config

    class ScopedStorage < Storage
      attr_reader :base_storage, :prefix
      def initialize(base_storage, prefix:)
        @base_storage = base_storage
        @prefix = prefix
      end

      def [](key)
        base_storage["#{prefix}.#{key}"]
      end

      def []=(key, value)
        base_storage["#{prefix}.#{key}"] = value
      end

      def has_key?(key)
        base_storage.has_key?("#{prefix}.#{key}")
      end

      def fetch(key, *args, &block)
        base_storage.fetch("#{prefix}.#{key}", *args, &block)
      end
    end

  end
end
