require 'pathname'
require 'hamster'

require_relative '../storage/file_storage'
require_relative 'adapter'

module Moltrio
  module Config
    class MultitenantDirectoryAdapter
      attr_reader :dir_path, :must_exist
      def initialize(config, dir_path, must_exist: false)
        @config = config
        @dir_path = Pathname(dir_path)
        @single_adapters = Hamster.hash
        @must_exist = must_exist
      end

      def missing_namespace?
        true
      end

      def on_namespace(namespace)
        unless adapter = single_adapters[namespace]
          adapter = create_single_adapter_for(namespace)
          @single_adapters = single_adapters.put(namespace, adapter)
        end

        adapter
      end

      def available_namespaces
        config_child_dirs = dir_path.children
          .select(&:directory?)
          .select { |dir| (dir + 'config.yml').file? }

        config_child_dirs.map { |dir| dir.basename.to_s }
      end

    private
      attr_reader :single_adapters, :config

      def create_single_adapter_for(namespace)
        path = dir_path + namespace.to_s + 'config.yml'
        SingleFileAdapter.new(config, path, must_exist: must_exist)
      end
    end
  end
end
