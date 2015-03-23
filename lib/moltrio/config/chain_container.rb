require_relative 'adapters'

module Moltrio
  module Config

    class ChainContainer
      def initialize(chains)
        @chains = chains
      end

      delegate(*Adapter.instance_methods(false), to: :default_chain)

      def default_chain
        chain(:default)
      end

      def available_namespaces(chain_name = :default)
        unless chain = chains[chain_name]
          raise "No chain named #{chain_name} chain configured!"
        end

        chain.available_namespaces
      end

      def chain(name)
        chain = chains[name]

        if chain.nil?
          raise "No chain named #{name.inspect} configured!"
        elsif chain.missing_namespace?
          raise "Chain #{name.inspect} requires namespace, but no namespace provided"
        else
          chain
        end
      end

    private
      attr_reader :chains
    end

  end
end
