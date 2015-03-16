require 'thread_attr_accessor'
require 'active_support/core_ext/module/delegation'

require_relative "config/version"

require_relative "config/builder"

require_relative 'config/adapter_chain'

require_relative 'config/file_storage'
require_relative 'config/database_yml_storage'
require_relative 'config/scoped_config'

module Moltrio
  module Config
    extend self

    def configure(&block)
      builder = Builder.run(&block)

      @chains = builder.chains
      @config = builder.config

      self
    end

    extend ThreadAttrAccessor
    thread_attr_accessor :current_namespace, inherit: true, private: true
    thread_attr_accessor :active_chains, inherit: true, private: true,
      default: -> { @chains }

    def switch_to_namespace(namespace)
      self.current_namespace = namespace
      self.active_chains = @chains.map { |chain_name, chain|
        [chain_name, chain.on_namespace(namespace)]
      }
      self
    end

    delegate :[], :[]=, :has_key?, :fetch, to: :default_chain

    def default_chain
      chain(:default)
    end

    def chain(name)
      chain = active_chains[name]

      if chain.nil?
        raise "No chain named #{name.inspect} configured!"
      elsif chain.requires_namespace? && !current_namespace
        raise "Chain #{name.inspect} requires namespace, but no namespace provided"
      else
        chain
      end
    end
  end
end
