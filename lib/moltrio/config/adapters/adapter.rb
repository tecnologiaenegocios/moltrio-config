require_relative '../undefined'

module Moltrio
  module Config

    class Adapter
      def on_namespace(_)
        if missing_namespace?
          raise NotImplementedError, "Please override on_namespace for #{self.class}!"
        else
          self
        end
      end

      def [](key)
        raise NotImplementedError
      end

      def []=(key, value)
        raise NotImplementedError
      end

      def has_key?(key)
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

      def missing_namespace?
        raise NotImplementedError,
          "Please define whether #{self.class} requires a namespace"
      end

      def available_namespaces
        []
      end
    end

  end
end
