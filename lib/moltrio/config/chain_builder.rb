require_relative 'adapters/multitenant_redis_adapter'
require_relative 'adapters/multitenant_directory_adapter'
require_relative 'adapters/single_redis_adapter'
require_relative 'adapters/single_file_adapter'
require_relative 'adapters/database_yml_adapter'
require_relative 'adapters/env_variables_adapter'

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
        link = SingleFileAdapter.new(config, *args)
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
