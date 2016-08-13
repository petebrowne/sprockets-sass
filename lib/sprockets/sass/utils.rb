# frozen_string_literal: true
module Sprockets
  module Sass
    # utility functions that can be used statically from anywhere
    class Utils
      class << self
        def full_version_of_sprockets
          Sprockets::VERSION
        end

        def version_of_sprockets
          full_version_of_sprockets.split('.')[0].to_i
        end

        def read_file_binary(file, options = {})
          default_encoding = options.delete :default_encoding

          # load template data and prepare (uses binread to avoid encoding issues)
          data = read_template_file(file)

          if data.respond_to?(:force_encoding)
            if default_encoding
              data = data.dup if data.frozen?
              data.force_encoding(default_encoding)
            end

            unless data.valid_encoding?
              raise Encoding::InvalidByteSequenceError, "#{filename} is not valid #{data.encoding}"
            end
          end
          data
        end

        def digest(options)
          options.delete_if { |_key, value| value.is_a?(Pathname) } if options.is_a?(Hash)
          options = options.to_s unless options.is_a?(Hash)
          if defined?(Sprockets::DigestUtils)
            Sprockets::DigestUtils.digest(options)
          else
            options = options.is_a?(Hash) ? options : { value: options }
            Digest::SHA256.hexdigest(JSON.generate(options))
          end
        end

        def read_template_file(file)
          data = File.open(file, 'rb', &:read)
          if data.respond_to?(:force_encoding)
            # Set it to the default external (without verifying)
            data.force_encoding(Encoding.default_external) if Encoding.default_external
          end
          data
        end

        def get_class_by_version(class_name, version = version_of_sprockets)
          constantize("Sprockets::Sass::V#{version}::#{class_name}")
        rescue
          nil
        end

        def constantize(camel_cased_word)
          names = camel_cased_word.split('::')

          # Trigger a built-in NameError exception including the ill-formed constant in the message.
          Object.const_get(camel_cased_word) if names.empty?

          # Remove the first blank element in case of '::ClassName' notation.
          names.shift if names.size > 1 && names.first.empty?

          names.reduce(Object) do |constant, name|
            if constant == Object
              constant.const_get(name)
            else
              candidate = constant.const_get(name)
              next candidate if constant.const_defined?(name, false)
              next candidate unless Object.const_defined?(name)

              # Go down the ancestors to check if it is owned directly. The check
              # stops when we reach Object or the end of ancestors tree.
              constant = constant.ancestors.each_with_object do |ancestor, const|
                break const    if ancestor == Object
                break ancestor if ancestor.const_defined?(name, false)
                const
              end

              # owner is in Object, so raise
              constant.const_get(name, false)
            end
          end
        end

        def module_include(base, mod)
          old_methods = {}

          mod.instance_methods.each do |sym|
            old_methods[sym] = base.instance_method(sym) if base.method_defined?(sym)
          end

          mod.instance_methods.each do |sym|
            method = mod.instance_method(sym)
            base.send(:define_method, sym, method)
          end

          yield
        ensure
          mod.instance_methods.each do |sym|
            base.send(:undef_method, sym) if base.method_defined?(sym)
          end
          old_methods.each do |sym, method|
            base.send(:define_method, sym, method)
          end
        end
      end
    end
  end
end
