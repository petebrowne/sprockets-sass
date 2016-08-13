# frozen_string_literal: true
module Sprockets
  module Sass
    # class useful for registering engines, tranformers, preprocessors and conpressors for sprockets
    # depending on the version of sprockets
    class Registration
      attr_reader :klass, :sprockets_version, :registration_instance

      def initialize(klass)
        @klass = klass
        @sprockets_version = Sprockets::Sass::Utils.version_of_sprockets
        @registration_instance = self
      end

      def run
        require_libraries
        case @sprockets_version
          when 2...3
            register_sprockets_legacy
          when 3...4
            register_sprockets_v3
          when 4...5
            register_sprockets_v4
          else
            raise "Version #{Sprockets::Sass::Utils.full_version_of_sprockets} is not supported"
        end
      end

      def require_libraries
        require_standard_libraries
        require 'sprockets/sass/functions'
      end

    private

      def require_standard_libraries(version = @sprockets_version)
        %w(cache_store compressor functions importer sass_template scss_template).each do |filename|
          begin
            require "sprockets/sass/v#{version}/#{filename}"
          rescue LoadError; end
        end
      end

      def register_sprockets_v3_common
        %w(sass scss).each do |mime|
          _register_mime_types(mime_type:  "application/#{mime}+ruby", extensions: [".#{mime}.erb", ".css.#{mime}.erb"])
        end
        _register_compressors(mime_type: 'text/css', name: :sprockets_sass, klass: Sprockets::Sass::Utils.get_class_by_version('Compressor'))
      end

      def register_sprockets_v4
        register_sprockets_v3_common
        %w(sass scss).each do |mime|
          _register_mime_types(mime_type:  "text/#{mime}", extensions: [".#{mime}", ".css.#{mime}"])
        end
        %w(sass scss).each do |mime|
          _register_transformers(from: "application/#{mime}+ruby", to: "text/#{mime}", klass: Sprockets::ERBProcessor)
        end
        _register_v4_preprocessors(
          Sprockets::Sass::V4::SassTemplate => ['text/sass'],
          Sprockets::Sass::V4::ScssTemplate => ['text/scss']
        )
        _register_transformers(
          { from: 'text/sass', to: 'text/css', klass: Sprockets::Sass::V4::SassTemplate },
          from: 'text/scss', to: 'text/css', klass: Sprockets::Sass::V4::ScssTemplate
        )
      end

      def register_sprockets_v3
        register_sprockets_v3_common
        _register_transformers(
          { from: 'application/scss+ruby', to: 'text/css', klass: Sprockets::ERBProcessor },
          from: 'application/sass+ruby', to: 'text/css', klass: Sprockets::ERBProcessor
        )
        _register_engines('.sass' => Sprockets::Sass::V3::SassTemplate, '.scss' => Sprockets::Sass::V3::ScssTemplate)
      end

      def register_sprockets_legacy
        _register_engines('.sass' => Sprockets::Sass::V2::SassTemplate, '.scss' => Sprockets::Sass::V2::ScssTemplate)
      end

      def _register_engines(hash)
        hash.each do |key, value|
          args = [key, value]
          args << { mime_type: 'text/css', silence_deprecation: true } if sprockets_version >= 3
          register_engine(*args)
        end
      end

      def _register_mime_types(*mime_types)
        mime_types.each do |mime_data|
          register_mime_type(mime_data[:mime_type], extensions: mime_data[:extensions])
        end
      end

      def _register_compressors(*compressors)
        compressors.each do |compressor|
          register_compressor(compressor[:mime_type], compressor[:name], compressor[:klass])
        end
      end

      def _register_transformers(*tranformers)
        tranformers.each do |tranformer|
          register_transformer(tranformer[:from], tranformer[:to], tranformer[:klass])
        end
      end

      def _register_v4_preprocessors(hash)
        hash.each do |key, value|
          value.each do |mime|
            register_preprocessor(mime, key)
          end
        end
      end

      def method_missing(sym, *args, &block)
        @klass.public_send(sym, *args, &block) || super
      end

      def respond_to_missing?(method_name, include_private = nil)
        include_private = include_private.blank? ? true : include_private
        @klass.public_methods.include?(method_name) || super(method_name, include_private)
      end
    end
  end
end
