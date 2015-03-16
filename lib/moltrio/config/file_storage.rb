require 'yaml'
require 'hamster'
require 'erb'

require_relative 'storage'

# This class uses Hamster hashes (instead of native ruby hashes) to allow
# lockless multi-thread usage.

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
          hamster_to_ruby(traverse(path).fetch(leaf))
        else
          nil
        end
      end

      def []=(dotted_key, value)
        ancestor_keys = splitted_key(dotted_key)
        current_value = value
        base_hash = hash

        while ancestor_keys.any?
          *ancestor_keys, current_key = ancestor_keys

          old_value = traverse(ancestor_keys, base_hash: base_hash)
          current_value = old_value.put(current_key, current_value)
        end

        unless @hash.equal?(base_hash)
          # Retry the change. The hash was updated by other thread while we
          # were computing the new hash.
          return self[dotted_key] = value
        end

        @hash = current_value

        save
      end

      def has_key?(key)
        not_found = Object.new
        value = splitted_key(key).inject(hash) do |current, part|
          if current.respond_to?(:has_key?) && current.has_key?(part)
            current[part]
          else
            break not_found
          end
        end

        !value.equal?(not_found)
      end

      def on_namespace(namespace)
        scoped(namespace)
      end

    private

      def hash
        @hash ||= load_from_file
      end

      def splitted_key(key)
        key.to_s.split('.')
      end

      def traverse(splitted_key, base_hash: hash)
        splitted_key.inject(base_hash) { |object, current_key|
          if object.respond_to?(:has_key?) && object.has_key?(current_key)
            object.fetch(current_key)
          else
            break Hamster.hash
          end
        }
      end

      def load_from_file
        ruby_hash = begin
          file = File.open(path, "r")
          file.flock(File::LOCK_SH)

          YAML.load_file(path)
        rescue Errno::ENOENT
        ensure
          file && file.flock(File::LOCK_UN)
        end

        ruby_to_hamster(ruby_hash || {})
      rescue Errno::ENOENT
        Hamster.hash
      end

      def save
        unless File.exist?(path)
          FileUtils.mkdir_p(File.dirname(path))
        end

        file = File.open(path, "w")
        file.flock(File::LOCK_EX)

        file.write YAML.dump(hamster_to_ruby(hash))
      ensure
        file.flock(File::LOCK_UN)
        file.close
      end

      def hamster_to_ruby(object)
        return object unless object.kind_of?(Hamster::Hash)

        object.inject({}) { |hash, key, value|
          hash[key] = hamster_to_ruby(value)
          hash
        }
      end

      # Not concerned about circular structures here, since this is just for
      # internal usage.
      def ruby_to_hamster(object)
        return object unless object.kind_of?(Hash)

        object.inject(Hamster.hash) { |hash, (key, value)|
          hash.put(key, ruby_to_hamster(value))
        }
      end
    end

  end
end
