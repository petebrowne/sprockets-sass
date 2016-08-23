# frozen_string_literal: true
module Sprockets
  module Sass
    module V2
      # Preprocessor for SASS files
      class SassTemplate
        VERSION = '1'

        def self.default_mime_type
          'text/css'
        end

        # Internal: Defines default sass syntax to use. Exposed so the ScssProcessor
        # may override it.
        def self.syntax
          :sass
        end

        # Public: Return singleton instance with default options.
        #
        # Returns SassProcessor object.
        def self.instance
          @instance ||= new
        end

        def self.call(input)
          instance.call(input)
        end

        def self.cache_key
          instance.cache_key
        end

        attr_reader :cache_key, :filename, :source, :context, :options

        def initialize(options = {}, &block)
          @default_options = { default_encoding: Encoding.default_external || 'utf-8' }
          initialize_engine
          if options.is_a?(Hash)
            instantiate_with_options(options, &block)
          else
            instantiate_with_filename_and_source(options, &block)
          end
        end

        def instantiate_with_filename_and_source(options)
          @filename = options
          @source = block_given? ? yield : nil
          @options = @default_options
          @cache_version = VERSION
          @cache_key = "#{self.class.name}:#{::Sass::VERSION}:#{VERSION}:#{Sprockets::Sass::Utils.digest(options)}"
          @functions = Module.new do
            include Sprockets::Helpers if defined?(Sprockets::Helpers)
            include Sprockets::Sass::Utils.get_class_by_version('Functions')
          end
        end

        def instantiate_with_options(options, &block)
          @cache_version = options[:cache_version] || VERSION
          @cache_key = "#{self.class.name}:#{::Sass::VERSION}:#{@cache_version}:#{Sprockets::Sass::Utils.digest(options)}"
          @filename = options[:filename]
          @source = options[:data]
          @options = options.merge(@default_options)
          @importer_class = options[:importer]
          @sass_config = options[:sass_config] || {}
          @input = options
          @functions = Module.new do
            include Sprockets::Helpers if defined?(Sprockets::Helpers)
            include Sprockets::Sass::Utils.get_class_by_version('Functions')
            include options[:functions] if options[:functions]
            class_eval(&block) if block_given?
          end
        end

        @sass_functions_initialized = false
        class << self
          attr_accessor :sass_functions_initialized
          alias sass_functions_initialized? sass_functions_initialized
          # Templates are initialized once the functions are added.
          def engine_initialized?
            sass_functions_initialized?
          end
        end

        # Add the Sass functions if they haven't already been added.
        def initialize_engine
          return if self.class.engine_initialized?

          if Sass.add_sass_functions != false
            begin
              require 'sprockets/helpers'
              require 'sprockets/sass/functions'
              self.class.sass_functions_initialized = true
            rescue LoadError; end
          end
        end

        def call(input)
          @input = input
          @filename = input[:filename]
          @source   = input[:data]
          @context  = input[:environment].context_class.new(input)
          run
        end

        def render(context, _empty_hash_wtf)
          @context = context
          run
        end

        def run
          data = Sprockets::Sass::Utils.read_file_binary(filename, options)

          engine = ::Sass::Engine.new(data, sass_options)
          css = Sprockets::Sass::Utils.module_include(::Sass::Script::Functions, @functions) do
            css = engine.render
          end

          sass_dependencies = Set.new([filename])
          if context.respond_to?(:metadata)
            engine.dependencies.map do |dependency|
              sass_dependencies << dependency.options[:filename]
              context.metadata[:dependencies] << Sprockets::URIUtils.build_file_digest_uri(dependency.options[:filename])
            end
            context.metadata.merge(data: css, sass_dependencies: sass_dependencies)
          else
            css
          end

          #  Tilt::SassTemplate.new(filename, sass_options(filename, context)).render(self)
        rescue => e
          # Annotates exception message with parse line number
          # context.__LINE__ = e.sass_backtrace.first[:line]
          raise [e, e.backtrace].join("\n")
        end

        def merge_sass_options(options, other_options)
          if (load_paths = options[:load_paths]) && (other_paths = other_options[:load_paths])
            other_options[:load_paths] = other_paths + load_paths
          end
          options = options.merge(other_options)
          options[:load_paths] = options[:load_paths].is_a?(Array) ? options[:load_paths] : []
          options[:load_paths] = options[:load_paths].concat(context.environment.paths)
          options
        end

        def default_sass_config
          if defined?(Compass)
            merge_sass_options Compass.sass_engine_options.dup, Sprockets::Sass.options
          else
            Sprockets::Sass.options.dup
          end
        end

        def default_sass_options
          sass = default_sass_config
          sass = merge_sass_options(sass.dup, @sass_config) if defined?(@sass_config) && @sass_config.is_a?(Hash)
          sass
        end

        def build_cache_store(context)
          return nil if context.environment.cache.nil?
          if defined?(Sprockets::SassProcessor::CacheStore)
            Sprockets::SassProcessor::CacheStore.new(context.environment)
          else
            custom_cache_store(context.environment)
          end
        end

        def custom_cache_store(*args)
          Sprockets::Sass::V2::CacheStore.new(*args)
        end

        # Allow the use of custom SASS importers, making sure the
        # custom importer is a `Sprockets::Sass::Importer`
        def fetch_importer_class
          if defined?(@importer_class) && !@importer_class.nil?
            @importer_class
          elsif default_sass_options.key?(:importer) && default_sass_options[:importer].is_a?(Importer)
            default_sass_options[:importer]
          else
            custom_importer_class
          end
        end

        def custom_importer_class(*_args)
          Sprockets::Sass::V2::Importer.new
        end

        def fetch_sprockets_options
          sprockets_options = {
            context: context,
            environment: context.environment,
            dependencies: context.respond_to?(:metadata) ? context.metadata[:dependencies] : []
          }
          if context.respond_to?(:metadata)
            sprockets_options.merge(load_paths: context.environment.paths + default_sass_options[:load_paths])
          end
          sprockets_options
        end

        def sass_options
          importer = fetch_importer_class
          sprockets_options = fetch_sprockets_options

          sass = merge_sass_options(default_sass_options, options).merge(
            filename: filename,
            line: 1,
            syntax: self.class.syntax,
            cache: true,
            cache_store: build_cache_store(context),
            importer: importer,
            custom: { sprockets_context: context },
            sprockets: sprockets_options
          )
          sass
        end
      end
    end
  end
end
