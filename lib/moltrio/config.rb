require 'thread_attr_accessor'
require 'active_support/core_ext/module/delegation'

require_relative "config/version"
require_relative "config/builder"
require_relative 'config/scoped_config'
require_relative 'config/chain_container'

module Moltrio
  module Config
    extend self

    def configure(&block)
      @configuration_block = block
      self
    end

    extend ThreadAttrAccessor
    thread_attr_accessor :current_namespace, inherit: true, private: :writer
    thread_attr_accessor :cached_containers, inherit: true, private: true

    def enable_caching
      self.cached_containers ||= {}
    end

    def disable_caching
      self.cached_containers = nil
    end

    def on_namespace(namespace)
      if block_given?
        prev_namespace = current_namespace
        self.current_namespace = namespace

        if cached_containers
          cached_containers.delete(:namespaced)
        end

        begin
          value = yield
        ensure
          self.current_namespace = prev_namespace
        end

        value
      else
        ChainContainer.new(chains_on_namespace(namespace))
      end
    end

    delegate :[], :[]=, :has_key?, :fetch, :scoped, to: :default_chain
    delegate :available_namespaces, to: :root_container
    delegate :chain, to: :namespaced_container

    def default_chain
      chain(:default)
    end

  private

    def root_container
      return cached_containers[:root] if cached_containers && cached_containers[:root]
      container = ChainContainer.new(root_chains)

      if cached_containers
        cached_containers[:root] = container
      end

      container
    end

    def namespaced_container
      return cached_containers[:namespaced] if cached_containers && cached_containers[:namespaced]

      if current_namespace
        container = ChainContainer.new(chains_on_namespace(current_namespace))
      else
        container = root_container
      end

      if cached_containers
        cached_containers[:namespaced_chains] = chains
      end

      container
    end

    def root_chains
      Builder.run(&@configuration_block).chains
    end

    def chains_on_namespace(namespace)
      root_chains.map { |chain_name, chain|
        [chain_name, chain.on_namespace(namespace)]
      }
    end
  end
end
