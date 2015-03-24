module Moltrio
  module Config
    class NoSuchNamespace < Exception
      def initialize(namespace)
        @namespace = namespace
      end

      def message
        "The requested namespace ('#{@namespace}') does not exist"
      end
    end
  end
end
