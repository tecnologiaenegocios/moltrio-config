require 'hamster'
require_relative 'chain_builder'

module Moltrio
  module Config
    class Builder
      def self.run(&block)
        builder = new
        builder.instance_exec(&block)
        builder
      end

      attr_reader :chains, :config
      def initialize
        @chains = Hamster.hash
        @config = Hamster.hash
      end

      def chain(name, &block)
        chain = ChainBuilder.run(@config, &block)
        @chains = @chains.put(name, chain)
      end

      def redis(callable)
        @config = @config.put(:redis, callable.to_proc)
      end
    end
  end
end
