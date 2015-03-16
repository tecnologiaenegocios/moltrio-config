require 'pathname'
require_relative '../storage/file_storage'
require_relative 'adapter'

module Moltrio
  module Config
    class SingleFileAdapter < Adapter
      attr_reader :file_must_exist
      def initialize(config, path, file_must_exist: false)
        @path = path

        if file_must_exist && !Pathname(path).file?
          raise "File '#{path}' doesn't exist!"
        end
      end

      def requires_namespace?
        false
      end

    private

      def storage
        @storage ||= FileStorage.new(@path)
      end
    end
  end
end
