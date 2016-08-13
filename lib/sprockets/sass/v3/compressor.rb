# frozen_string_literal: true

module Sprockets
  module Sass
    module V3
      # Class used to compress CSS files
      class Compressor
        VERSION = '1'

        def self.default_mime_type
          'text/css'
        end

        # Public: Return singleton instance with default options.
        #
        # Returns SassCompressor object.
        def self.instance
          @instance ||= new
        end

        def self.call(input)
          instance.call(input)
        end

        def self.cache_key
          instance.cache_key
        end

        attr_reader :cache_key, :input, :filename, :source, :options, :context

        def initialize(options = {})
          @default_options = {
            syntax: :scss,
            cache: false,
            read_cache: false,
            style: :compressed,
            default_encoding: Encoding.default_external || 'utf-8'
          }
          @options = @default_options
          @cache_key = "#{self.class.name}:#{::Sass::VERSION}:#{VERSION}:#{Sprockets::Sass::Utils.digest(options)}"
          if options.is_a?(Hash)
            @input = options
            @filename = options[:filename]
            @source = options[:data]
            @options = @options.merge(options)
          else
            @filename = options
            @source = block_given? ? yield : nil
          end
        end

        def call(input)
          @input = input
          if input.is_a?(Hash)
            @filename = input[:filename]
            @source   = input[:data]
            @context  = input[:environment].context_class.new(input)
          end
          data = filename || @input
          run(data)
        end

        def render(context, _empty_hash_wtf)
          @context = context
          run(filename)
        end

        def self.compress(input)
          call(input)
        end

        def run(string)
          data = File.exist?(string.to_s) ? Sprockets::Sass::Utils.read_file_binary(string, options) : string
          if data.count("\n") >= 2
            engine = ::Sass::Engine.new(data, @options.merge(filename: filename))
            css = engine.render
            # this is defined when using sprockets environment,
            # but is not defined when calling directly in tests
            # unless using the manifest to compile the assets
            if defined?(@context) && @context.respond_to?(:metadata)
              sass_dependencies = Set.new([filename])
              engine.dependencies.map do |dependency|
                sass_dependencies << dependency.options[:filename]
                context.metadata[:dependencies] << Sprockets::URIUtils.build_file_digest_uri(dependency.options[:filename])
              end
              context.metadata.merge(data: css, sass_dependencies: sass_dependencies)
            else
              css
            end
          else
            data
          end
        end
      end
    end
  end
end
