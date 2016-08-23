# frozen_string_literal: true
require_relative '../v3/importer'
module Sprockets
  module Sass
    module V4
      # class used for importing files from SCCS and SASS files
      class Importer < Sprockets::Sass::V3::Importer
        def syntax_mime_type(path)
          "text/#{syntax(path)}"
        end

        def engine_from_glob(glob, base_path, options)
          context = options[:custom][:sprockets_context]
          engine_imports = resolve_glob(context, glob, base_path).reduce(''.dup) do |imports, path|
            context.depend_on path[:file_url]
            relative_path = path[:path].relative_path_from Pathname.new(base_path).dirname
            imports << %(@import "#{relative_path}";\n)
          end
          return nil if engine_imports.empty?
          ::Sass::Engine.new engine_imports, options.merge(
            filename: base_path.to_s,
            syntax: syntax(base_path.to_s),
            importer: self,
            custom: { sprockets_context: context }
          )
        end

        # Finds all of the assets using the given glob.
        def resolve_glob(context, glob, base_path)
          base_path      = Pathname.new(base_path)
          path_with_glob = base_path.dirname.join(glob).to_s

          glob_files = Pathname.glob(path_with_glob).sort.reduce([]) do |imports, path|
            pathname = resolve(context, path, base_path)
            asset_requirable = asset_requirable?(context, pathname)
            imports << { file_url: pathname, path: path } if path != context.filename && asset_requirable
          end
          glob_files
        end

        def possible_files(context, path, base_path)
          filename = check_path_before_process(context, base_path)
          base_path = (filename.is_a?(Pathname) ? filename : Pathname.new(filename))
          super(context, path, base_path)
        end

        def check_path_before_process(context, path, a = nil)
          if path.to_s.start_with?('file://')
            path = Pathname.new(path.to_s.gsub(/\?type\=(.*)/, "?type=text/#{syntax(path)}"))  # @TODO : investigate why sometimes file:/// URLS are ending in ?type=text instead of ?type=text/scss
            asset = context.environment.load(path) # because resolve now returns file://
            asset.filename
          else
            path
          end
        end

        def stat_of_pathname(context, pathname, _path)
          filename = check_path_before_process(context, pathname)
          context.environment.stat(filename)
        end

        # @TODO find better alternative than scanning file:// string for mime type
        def content_type_of_path(context, path)
          pathname = context.resolve(path)
          content_type = pathname.nil? ? nil : pathname.to_s.scan(/\?type\=(.*)/).flatten.first unless pathname.nil?
          attributes = {}
          [content_type, attributes]
        end

        def get_context_transformers(context, content_type, path)
          available_transformers =  context.environment.transformers[content_type]
          additional_transformers = available_transformers.key?(syntax_mime_type(path)) ? available_transformers[syntax_mime_type(path)] : []
          additional_transformers.is_a?(Array) ? additional_transformers : [additional_transformers]
          css_transformers = available_transformers.key?('text/css') ? available_transformers['text/css'] : []
          css_transformers = css_transformers.is_a?(Array) ? css_transformers : [css_transformers]
          additional_transformers = additional_transformers.concat(css_transformers)
          additional_transformers
        end

        def filter_all_processors(processors)
          processors.delete_if do |processor|
            filtered_processor_classes.include?(processor) || filtered_processor_classes.any? do |filtered_processor|
              !processor.is_a?(Proc) && ((processor.class != Class && processor.class < filtered_processor) || (processor.class == Class && processor < filtered_processor))
            end
          end
        end

        def call_processor_input(processor, context, input, processors)
          if processor.respond_to?(:processors)
            processor.processors = filter_all_processors(processor.processors)
          end
          super(processor, context, input, processors)
        end

        def filtered_processor_classes
          classes = super
          classes << Sprockets::SassCompressor if defined?(Sprockets::SassCompressor)
          classes << Sprockets::SasscCompressor if defined?(Sprockets::SasscCompressor)
          classes << Sprockets::YUICompressor if defined?(Sprockets::YUICompressor)
          classes
        end
      end
    end
  end
end
