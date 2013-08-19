require 'yaml'

module Moltrio
  module Config

    class FileStorage < Storage
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def [](key)
        if has_key?(key)
          traverse(splitted_key(key))
        else
          nil
        end
      end

      def []=(key, value)
        # ensure_granted!
        parent_key, key = split_key(key)
        parent_hash = traverse(parent_key)
        parent_hash[key] = value
        save
      end

      def has_key?(key)
        not_found = Object.new
        value = splitted_key(key).inject(hash) do |current, part|
          if current.has_key?(part)
            current[part]
          else
            break not_found
          end
        end

        !value.equal?(not_found)
      end

    private
      def ensure_granted!
        AccessControl.manager.can!(
          AccessControl.registry.fetch('change_system_configuration'),
          []
        )
      end

      def ensure_loaded
        load unless loaded?
      end

      def split_key(key)
        ->(parts) { [parts[0..-2], parts.last] }[splitted_key(key)]
      end

      def splitted_key(key)
        key.to_s.split('.').map(&:to_s)
      end

      def traverse(splitted)
        splitted.inject(hash) { |current, part| current[part] ||= {} }
      end

      def hash
        ensure_loaded
        @hash ||= {}
      end

      def load
        @hash = YAML.load_file(path) if File.file?(path)
        @loaded = true
      end

      def loaded?
        !!@loaded
      end

      def save
        File.write(path, YAML.dump(hash))
      end
    end

  end
end
