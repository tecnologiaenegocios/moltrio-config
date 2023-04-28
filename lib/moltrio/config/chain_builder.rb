require 'hamster'
require 'active_support'
require 'active_support/core_ext'
require_relative 'adapters'
require_relative 'adapter_chain'

module Moltrio
  module Config
    class ChainBuilder
      def self.run(config, &block)
        builder = new(config)
        builder.instance_exec(&block)
        builder.chain
      end

      def initialize(config)
        @config = config
        @links = Hamster.vector
      end

      def multitenant_redis(*args)
        link = MultitenantRedisAdapter.new(config, *args)
        @links = @links << link
      end

      def single_redis(*args)
        link = SingleRedisAdapter.new(config, *args)
        @links = @links << link
      end

      def single_file(*args)
        args.prepend config
        opts = args.extract_options!
        link = SingleFileAdapter.new(*args, **opts)
        @links = @links << link
      end

      def multitenant_directory(*args)
        link = MultitenantDirectoryAdapter.new(config, *args)
        @links = @links << link
      end

      def database_yml(path)
        link = DatabaseYmlAdapter.new(path)
        @links = @links << link
      end

      def env_variables(prefix)
        link = EnvVariablesAdapter.new(prefix)
        @links = @links << link
      end

      def chain
        AdapterChain.new(@links)
      end

    private
      attr_reader :config
    end
  end
end
