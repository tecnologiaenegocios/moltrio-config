module Moltrio
  module Config
    module Listener

      FS_POLL_INTERVAL = 5

      def self.listen_fs_changes
        if defined?(@fs_listener)
          @fs_listener.terminate
          Moltrio::Config.evict_all_caches
        end

        @fs_listener = Thread.new do
          Thread.current.abort_on_exception = true

          prev_timestamps = {}
          project_root = Rails.root

          clients_root = project_root + 'clients'
          global_configs_root = project_root + 'config' + 'moltrio'

          loop do
            found_configs = 0

            clients_root.each_child do |client_dir|
              client_name = client_dir.basename.to_s

              change_time = begin
                (client_dir + 'config.yml').mtime
              rescue Errno::ENOENT
                next
              end

              prev_time = prev_timestamps[client_name]
              if prev_time && prev_time < change_time
                Moltrio::Config.evict_cache_for(client_name)
              end

              found_configs += 1
              prev_timestamps[client_name] = change_time
            end

            global_configs_root.each_child do |global_config|
              config_name = global_config.basename.to_s
              change_time = global_config.mtime

              prev_time = prev_timestamps[config_name]
              if prev_time && prev_time < change_time
                Moltrio::Config.evict_all_caches
              end

              found_configs += 1
              prev_timestamps[config_name] = change_time
            end

            if prev_timestamps.count > found_configs
              prev_timestamps = {}
              Moltrio::Config.evict_all_caches
            end

            sleep FS_POLL_INTERVAL
          end
        end

        self
      end

      def self.listen_etcd_changes
        if defined?(@fs_listener)
          @etcd_listener.terminate
          Moltrio::Config.evict_all_caches
        end

        etcd_host = Moltrio::Config.storage_options.fetch(:etcd_host)
        etcd_port = Moltrio::Config.storage_options.fetch(:etcd_port)

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

      def self.start
        storage = Moltrio::Config.storage_type
        case storage
          when :filesystem
            listen_fs_changes
          when :etcd
            listen_etcd_changes
          else
            raise "Don't know how to auto-reload for #{storage}"
        end
      end

    end
  end
end
