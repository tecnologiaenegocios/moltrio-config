require 'thread_attr_accessor'

require_relative "config/version"

require_relative 'config/listener'
require_relative 'config/storage_chain'
require_relative 'config/file_storage'
require_relative 'config/etcd_storage'
require_relative 'config/database_yml_storage'
require_relative 'config/scoped_config'

module Moltrio
  module Config
    def self.configure
      yield self
      freeze
    end

    def self.storage_type
      @storage_type ||= :filesystem
    end

    VALID_STORAGE_TYPES = %i(etcd filesystem)
    def self.storage_type=(storage_type)
      unless VALID_STORAGE_TYPES.include?(storage)
        raise "#{storage} is not valid. Pleases select one of #{VALID_STORAGE_TYPES}"
      end

      @storage_type = storage_type
    end

    def self.storage_options
      @storage_options ||= {}
    end
  end
end
