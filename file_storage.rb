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
          *path, leaf = splitted_key(key)
          traverse(path).fetch(leaf)
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

      def hash
        return @hash if defined?(@hash)
        @hash = load_from_file
      end

      def split_key(key)
        ->(parts) { [parts[0..-2], parts.last] }[splitted_key(key)]
      end

      def splitted_key(key)
        key.to_s.split('.')
      end

      def traverse(splitted)
        splitted.inject(hash) { |current, part| current[part] ||= {} }
      end

      def load_from_file
        preprocessed = ERB.new(File.read(path)).result
        YAML.load(preprocessed)
      rescue Errno::ENOENT
        nil
      end

      def save
        File.write(path, YAML.dump(hash))
      end
    end

  end
end
