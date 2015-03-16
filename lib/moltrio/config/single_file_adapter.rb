require_relative "file_storage"

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
