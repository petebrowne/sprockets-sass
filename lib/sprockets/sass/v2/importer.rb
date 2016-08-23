# frozen_string_literal: true

module Sprockets
  module Sass
    module V2
      # class used for importing files from SCCS and SASS files
      class Importer < ::Sass::Importers::Base
        GLOB = /\*|\[.+\]/

        # @see Sass::Importers::Base#find_relative
        def find_relative(path, base_path, options)
          if path.to_s =~ GLOB
            engine_from_glob(path, base_path, options)
          else
            engine_from_path(path, base_path, options)
          end
        end

        # @see Sass::Importers::Base#find
        def find(path, options)
          engine_from_path(path, nil, options)
        end

        # @see Sass::Importers::Base#mtime
        def mtime(path, _options)
          if pathname = resolve(path)
            pathname.mtime
          end
        rescue Errno::ENOENT
          nil
        end

        # @see Sass::Importers::Base#key
        def key(path, _options)
          path = Pathname.new(path)
          ["#{self.class.name}:#{path.dirname.expand_path}", path.basename]
        end

        # @see Sass::Importers::Base#to_s
        def to_s
          inspect
        end

      protected

        # Create a Sass::Engine from the given path.
        def engine_from_path(path, base_path, options)
          context = options[:custom][:sprockets_context]
          (pathname = resolve(context, path, base_path)) || (return nil)
          context.depend_on pathname
          ::Sass::Engine.new evaluate(context, pathname), options.merge(
            filename: pathname.to_s,
            syntax: syntax(pathname),
            importer: self,
            custom: { sprockets_context: context }
          )
        end

        # Create a Sass::Engine that will handle importing
        # a glob of files.
        def engine_from_glob(glob, base_path, options)
          context = options[:custom][:sprockets_context]
          engine_imports = resolve_glob(context, glob, base_path).reduce(''.dup) do |imports, path|
            context.depend_on path
            relative_path = path.relative_path_from Pathname.new(base_path).dirname
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

        # Finds an asset from the given path. This is where
        # we make Sprockets behave like Sass, and import partial
        # style paths.
        def resolve(context, path, base_path)
          paths, _root_path = possible_files(context, path, base_path)
          paths.each do |file|
            context.resolve(file.to_s) do |found|
              return found if context.asset_requirable?(found)
            end
          end
          nil
        end

        # Finds all of the assets using the given glob.
        def resolve_glob(context, glob, base_path)
          base_path      = Pathname.new(base_path)
          path_with_glob = base_path.dirname.join(glob).to_s

          Pathname.glob(path_with_glob).sort.select do |path|
            asset_requirable = context.asset_requirable?(path)
            path != context.pathname && asset_requirable
          end
        end

        def context_root_path(context)
          Pathname.new(context.root_path)
        end

        def context_load_pathnames(context)
          context.environment.paths.map { |p| Pathname.new(p) }
        end

        # Returns all of the possible paths (including partial variations)
        # to attempt to resolve with the given path.
        def possible_files(context, path, base_path)
          path      = Pathname.new(path)
          base_path = Pathname.new(base_path).dirname
          partial_path = partialize_path(path)
          additional_paths = [Pathname.new("#{path}.css"), Pathname.new("#{partial_path}.css"), Pathname.new("#{path}.css.#{syntax(path)}"), Pathname.new("#{partial_path}.css.#{syntax(path)}")]
          paths = additional_paths.concat([path, partial_path])

          # Find base_path's root
          paths, root_path = add_root_to_possible_files(context, base_path, path, paths)
          [paths.compact, root_path]
        end

        def add_root_to_possible_files(context, base_path, path, paths)
          env_root_paths = context_load_pathnames(context)
          root_path = env_root_paths.find do |env_root_path|
            base_path.to_s.start_with?(env_root_path.to_s)
          end
          root_path ||= context_root_path(context)
          # Add the relative path from the root, if necessary
          if path.relative? && base_path != root_path
            relative_path = base_path.relative_path_from(root_path).join path
            paths.unshift(relative_path, partialize_path(relative_path))
          end
          [paths, root_path]
        end

        # Returns the partialized version of the given path.
        # Returns nil if the path is already to a partial.
        def partialize_path(path)
          return unless path.basename.to_s !~ /\A_/
          Pathname.new path.to_s.sub(/([^\/]+)\Z/, '_\1')
        end

        # Returns the Sass syntax of the given path.
        def syntax(path)
          path.to_s.include?('.sass') ? :sass : :scss
        end

        def syntax_mime_type(_path)
          'text/css'
        end

        def filtered_processor_classes
          classes = [Sprockets::Sass::Utils.get_class_by_version('SassTemplate'), Sprockets::Sass::Utils.get_class_by_version('ScssTemplate')]
          classes << Sprockets::SassProcessor if defined?(Sprockets::SassProcessor)
          classes << Sprockets::SasscProcessor if defined?(Sprockets::SasscProcessor)
          classes
        end

        def content_type_of_path(context, path)
          attributes = context.environment.attributes_for(path)
          content_type = attributes.content_type
          [content_type, attributes]
        end

        def get_context_preprocessors(context, content_type)
          context.environment.preprocessors(content_type)
        end

        def get_context_transformers(_context, _content_type, _path)
          []
        end

        def get_engines_from_attributes(attributes)
          attributes.engines
        end

        def get_all_processors_for_evaluate(context, content_type, attributes, path)
          engines = get_engines_from_attributes(attributes)
          preprocessors = get_context_preprocessors(context, content_type)
          additional_transformers = get_context_transformers(context, content_type, path)
          additional_transformers.reverse + preprocessors + engines.reverse
        end

        def filter_all_processors(processors)
          processors.delete_if do |processor|
            filtered_processor_classes.include?(processor) || filtered_processor_classes.any? do |filtered_processor|
              !processor.is_a?(Proc) && processor < filtered_processor
            end
          end
        end

        def evaluate_path_from_context(context, path, processors)
          context.evaluate(path, processors: processors)
        end

        # Returns the string to be passed to the Sass engine. We use
        # Sprockets to process the file, but we remove any Sass processors
        # because we need to let the Sass::Engine handle that.
        def evaluate(context, path)
          content_type, attributes = content_type_of_path(context, path)
          processors = get_all_processors_for_evaluate(context, content_type, attributes, path)
          filter_all_processors(processors)
          evaluate_path_from_context(context, path, processors)
        end
      end
    end
  end
end
