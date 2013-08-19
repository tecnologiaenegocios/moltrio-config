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

      def fetch(key, *args)
        return self[key] if has_key?(key)
        return args.first if args.size == 1

        raise KeyError, key
      end
    end
  end
end
