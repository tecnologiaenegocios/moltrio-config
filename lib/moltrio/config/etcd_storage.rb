require 'hamster'

module Moltrio
  module Config

    class EtcdStorage < Storage
      attr_reader :etcd, :namespace

      def initialize(etcd:, namespace:)
        @etcd = etcd
        @namespace = namespace
        @cache = Hamster.hash
      end

      def [](key)
        if cache.has_key?(key)
          cache[key]
        else
          etcd_key = etcdify_key(key)
          value = etcd.get(etcd_key)

          @cache = cache.put(key, value)
          value
        end
      end

      def []=(key, value)
        etcd_key = etcdify_key(key)
        etcd.set(etcd_key, value)

        @cache = cache.put(key, value)
      end

      def has_key?(key)
        !!self[key]
      end

    private
      attr_reader :cache

      def etcdify_key(key)
        namespace + '/' + key
      end
    end
  end
end
