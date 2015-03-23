require 'hamster'
require_relative 'adapters'

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
        if adapter = adapter_for_key(key)
          adapter[key]
        end
      end

      def []=(key, value)
        first_adapter[key] = value
      end

      def has_key?(key)
        !!adapter_for_key(key)
      end

      def missing_namespace?
        adapters.any?(&:missing_namespace?)
      end

      def available_namespaces
        adapters.reduce(Hamster.set) { |set, adapter|
          set.merge(adapter.available_namespaces)
        }
      end

    private
      attr_reader :adapters

      def adapter_for_key(key)
        adapters.detect { |adapter| adapter.has_key?(key) }
      end

      def first_adapter
        @adapters.first
      end
    end
  end
end
