require_relative 'adapter'

module Moltrio
  module Config

    # Work around circular dependency between Adapter and this class
    Adapter.class_eval do
      def scoped(scope)
        Scoped.new(self, scope)
      end
    end

    class Scoped < Adapter
      def initialize(base, scope)
        @base = base
        @scope = scope
      end

      class << self
        def delegate_to_base_scoping_first_argument(*delegations)
          delegations.each do |method|
            define_method(method) do |key, *args, &block|
              key = scope_key(key)
              base.public_send(method, key, *args, &block)
            end
          end
        end
      end

      def scoped(scope)
        self.class.new(self, scope)
      end

      delegate_to_base_scoping_first_argument :[], :[]=, :has_key?

    private
      attr_reader :base, :scope

      def scope_key(key)
        "#{scope}.#{key}"
      end
    end
  end
end
