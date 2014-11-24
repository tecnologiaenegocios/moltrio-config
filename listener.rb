require 'listen'

module Moltrio
  module Config
    module Listener

      FS_POLL_INTERVAL = 5

      def self.listen_fs_changes
        return if defined?(@fs_listener)

        @fs_listener = Thread.new do
          Thread.current.abort_on_exception = true

          prev_timestamps = {}
          project_root = Rails.root

          clients_root = project_root + 'clients'
          global_configs_root = project_root + 'config' + 'moltrio'

          loop do
            clients_root.each_child do |client_dir|
              client_name = client_dir.basename
              change_time = (client_dir + 'config.yml').mtime

              prev_time = prev_timestamps[client_name]
              if prev_time && prev_time < change_time
                Moltrio::Config.evict_cache_for(client_name)
              end

              prev_timestamps[client_name] = change_time
            end

            global_configs_root.each_child do |global_config|
              config_name = global_config.basename
              change_time = global_config.mtime

              prev_time = prev_timestamps[config_name]
              if prev_time && prev_time < change_time
                Moltrio::Config.evict_all_caches
              end

              prev_timestamps[config_name] = change_time
            end

            sleep FS_POLL_INTERVAL
          end
        end

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
