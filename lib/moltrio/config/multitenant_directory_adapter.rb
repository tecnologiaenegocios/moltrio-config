require 'pathname'
require 'hamster'

require_relative 'storage/file_storage'
require_relative 'adapter'

module Moltrio
  module Config
    class MultitenantDirectoryAdapter
      attr_reader :dir_path
      def initialize(config, dir_path)
        @config = config
        @dir_path = Pathname(dir_path)
        @single_adapters = Hamster.hash
      end

      def requires_namespace?
        true
      end

      def on_namespace(namespace)
        unless adapter = single_adapters[namespace]
          adapter = create_single_adapter_for(namespace)
          @single_adapters = single_adapters.put(namespace, adapter)
        end

        adapter
      end

    private
      attr_reader :single_adapters, :config

      def create_single_adapter_for(namespace)
        SingleFileAdapter.new(config, dir_path + namespace.to_s + 'config.yml')
      end
    end
  end
end
