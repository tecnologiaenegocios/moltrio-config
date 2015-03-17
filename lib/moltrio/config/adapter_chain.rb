require 'hamster'
require_relative 'adapters/adapter'

module Moltrio
  module Config
    class AdapterChain < Adapter
      def initialize(adapters)
        @adapters = Hamster.list(*adapters)
      end

      def on_namespace(namespace)
        adapters_on_namespace = adapters.map { |adapter|
          adapter.on_namespace(namespace)
        }

        self.class.new(adapters_on_namespace)
      end

      def [](key)
        if adapter = adapters_for_key(key).first
          adapter[key]
        end
      end

      def []=(key, value)
        first_adapter[key] = value
      end

      def has_key?(key)
        adapters_for_key(key).any?
      end

      def missing_namespace?
        adapters.any?(&:missing_namespace?)
      end

    private
      attr_reader :adapters

      def adapters_for_key(key)
        adapters.select { |adapter| adapter.has_key?(key) }
      end

      def first_adapter
        @adapters.first
      end
    end
  end
end
