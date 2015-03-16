require_relative "storage/file_storage"
require_relative 'adapter'

module Moltrio
  module Config
    class SingleFileAdapter < Adapter
      def initialize(config, path)
        @path = path
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
