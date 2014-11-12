require 'etcd'

module Moltrio
  module Config

    class EtcdStorage < Storage
      attr_reader :etcd, :namespace

      def initialize(etcd:, namespace:)
        @etcd = etcd
        @namespace = namespace
      end

      def [](key)
        etcd_key = etcdify_key(key)
        etcd.get(etcd_key)
      end

      def []=(key, value)
        etcd_key = etcdify_key(key)
        etcd.set(etcd_key, value)
      end

      def has_key?(key)
        !!self[key]
      end

    private

      def etcdify_key(key)
        namespace + '/' + key
      end
    end
  end
end
