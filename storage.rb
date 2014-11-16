require_relative '../undefined'

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

      def fetch(key, default = Moltrio::Undefined)
        if has_key?(key)
          self[key]
        elsif default != Moltrio::Undefined
          default
        elsif block_given?
          yield
        else
          raise KeyError, key
        end
      end
    end
  end
end
