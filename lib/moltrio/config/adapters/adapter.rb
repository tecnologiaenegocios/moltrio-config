require 'active_support/core_ext/module/delegation'

module Moltrio
  module Config

    class Adapter
      delegate :[], :[]=, :fetch, :has_key?, to: :storage

      def on_namespace(_)
        if missing_namespace?
          raise NotImplementedError, "Please override on_namespace for #{self.class}!"
        else
          self
        end
      end

      def missing_namespace?
        raise NotImplementedError,
          "Please define whether #{self.class} requires a namespace"
      end

    private

      def storage
        raise NotImplementedError, "Storage not defined for #{self.class}"
      end
    end

  end
end
