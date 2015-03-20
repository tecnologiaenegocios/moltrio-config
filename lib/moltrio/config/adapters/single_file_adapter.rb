require 'active_support/core_ext/module/delegation'
require 'pathname'

require_relative '../storage/file_storage'
require_relative 'adapter'

module Moltrio
  module Config
    class SingleFileAdapter < Adapter
      delegate :[], :[]=, :fetch, :has_key?, to: :storage

      attr_reader :must_exist
      def initialize(config, path, must_exist: false)
        @path = path

        if must_exist && !Pathname(path).file?
          raise "File '#{path}' doesn't exist!"
        end
      end

      def missing_namespace?
        false
      end

    private

      def storage
        @storage ||= FileStorage.new(@path)
      end
    end
  end
end
