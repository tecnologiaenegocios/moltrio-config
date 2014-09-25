module Moltrio
  class ScopedConfig
    def initialize(base, scope)
      @base = base
      @scope = scope
    end

    class << self
      def delegate_to_base_scoping_first_argument(*delegations)
        delegations.each do |method|
          define_method(method) do |*args, &block|
            base.public_send(method, *scope_first_argument(args), &block)
          end
        end
      end
    end

    def scoped(scope)
      self.class.new(self, scope)
    end

    delegate_to_base_scoping_first_argument :[], :[]=, :has_key?, :fetch

  private
    attr_reader :base, :scope

    def scoped_key(key)
      "#{scope}.#{key}"
    end

    def scope_first_argument(args)
      args.unshift(scoped_key(args.shift))
    end
  end
end
