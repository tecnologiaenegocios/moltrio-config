require_relative 'undefined'

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

      def fetch(key, default = Undefined)
        if has_key?(key)
          self[key]
        elsif default != Undefined
          default
        elsif block_given?
          yield
        else
          raise KeyError, key
        end
      end

      def scoped(prefix)
        ScopedStorage.new(self, prefix: prefix)
      end
    end
  end
end
