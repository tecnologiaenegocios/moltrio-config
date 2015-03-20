module Moltrio
  module Config
    class Storage
      def [](key)
        raise NotImplementedError
      end

      def []=(key, value)
        raise NotImplementedError
      end

      def has_key?(key)
        raise NotImplementedError
      end

      def on_namespace(namespace)
        raise NotImplementedError
      end
    end
  end
end
