require_relative 'storage'
require 'hamster'
require 'active_support/core_ext'

module Moltrio
  module Config
    class StorageChain < Storage

      def initialize(storages)
        @storages = Hamster.list(*storages)
      end

      def [](key)
        storages_for_key(key).inject { |prev_value, storage|
          value = storage.fetch(key)

          if prev_value.respond_to?(:deep_merge)
            prev_value.deep_merge(value)
          else
            value
          end
        }
      end

      def []=(key, value)
        first_storage[key] = value
      end

      def has_key?(key)
        storages_for_key(key).any?
      end

    private
      attr_reader :storages

      def storages_for_key(key)
        storages.select { |storage| storage.has_key?(key) }
      end

      def first_storage
        @storages.first
      end
    end
  end
end
