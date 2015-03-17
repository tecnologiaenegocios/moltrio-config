require 'thread_attr_accessor'
require 'active_support/core_ext/module/delegation'

require_relative "config/version"
require_relative "config/builder"
require_relative 'config/scoped_config'

module Moltrio
  module Config
    extend self

    def configure(&block)
      @configuration_block = block
      self
    end

    extend ThreadAttrAccessor
    thread_attr_accessor :current_namespace, inherit: true, private: true
    thread_attr_accessor :cached_chains, inherit: true, private: true

    def enable_caching
      self.cached_chains ||= {}
    end

    def disable_caching
      self.cached_chains = nil
    end

    def switch_to_namespace(namespace)
      self.current_namespace = namespace

      if cached_chains
        cached_chains.delete(:namespaced)
      end

      self
    end

    delegate :[], :[]=, :has_key?, :fetch, :scoped, to: :default_chain

    def default_chain
      chain(:default)
    end

    def chain(name)
      chain = namespaced_chains[name]

      if chain.nil?
        raise "No chain named #{name.inspect} configured!"
      elsif chain.missing_namespace?
        raise "Chain #{name.inspect} requires namespace, but no namespace provided"
      else
        chain
      end
    end

  private

    def root_chains
      return cached_chains[:root] if cached_chains && cached_chains[:root]

      chains = Builder.run(&@configuration_block).chains

      if cached_chains
        cached_chains[:root] = chains
      end

      chains
    end

    def namespaced_chains
      return cached_chains[:namespaced] if cached_chains && cached_chains[:namespaced]

      if current_namespace
        chains = root_chains.map { |chain_name, chain|
          [chain_name, chain.on_namespace(current_namespace)]
        }
      else
        chains = root_chains
      end

      if cached_chains
        cached_chains[:namespaced_chains] = chains
      end

      chains
    end
  end
end
