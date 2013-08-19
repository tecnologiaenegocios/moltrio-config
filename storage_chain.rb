require_relative 'storage'
require 'hamster'

module Moltrio
  module Config
    class StorageChain < Storage

      def initialize(storages)
        @storages = Hamster.list(*storages)
      end

      def [](key)
        storage = storage_for_key(key)

        if storage == :no_storage
          nil
        else
          storage[key]
        end
      end

      def []=(key, value)
        first_storage[key] = value
      end

      def has_key?(key)
        storage_for_key(key) != :no_storage
      end

    private
      attr_reader :storages

      def storage_for_key(key)
        @storages.detect { |storage| storage.has_key?(key) } || :no_storage
      end

      def first_storage
        @storages.first
      end
    end
  end
end
