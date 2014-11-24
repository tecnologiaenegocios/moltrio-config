require 'listen'

module Moltrio
  module Config
    module Listener

      def self.listen_fs_changes
        return if defined?(@fs_listeners)

        client_config_callback = ->(modified, added, removed) {
          all_changes = (modified + added + removed)

          all_changes.each do |config_path|
            config_name = Pathname(config_path).parent.basename.to_s
            Moltrio::Config.evict_cache_for(config_name)
          end
        }

        global_config_callback = ->(*) {
          Moltrio::Config.evict_all_caches
        }

        @fs_listeners = [
          Listen.to("clients/", only: /config.yml\z/, &client_config_callback),
          Listen.to("config/moltrio/", &global_config_callback),
        ]

        @fs_listeners.each(&:start)

        self
      end

      def self.listen_etcd_changes
        return if defined?(@etcd_listener)

        etcd_host = Moltrio.etcd_host
        etcd_port = Moltrio.etcd_port

        url = "http://#{etcd_host}:#{etcd_port}/v2/keys/moltrio".freeze

        @etcd_listener = Thread.new do
          Thread.current.abort_on_exception = true

          loop do
            begin
              response = HTTParty.get(url, query: { wait: true, recursive: true })
              changed_config_name = response["node"]["key"].split("/")[-2]

              if changed_config_name == "global_config"
                Moltrio::Config.evict_all_caches
              else
                Moltrio::Config.evict_cache_for(changed_config_name)
              end
            rescue Net::ReadTimeout, Net::OpenTimeout
              next
            end
          end
        end

        self
      end

      class << self
        if Moltrio.etcd_configured?
          alias_method :start, :listen_etcd_changes
        else
          alias_method :start, :listen_fs_changes
        end
      end

    end
  end
end
