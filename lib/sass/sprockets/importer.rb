require "sass/importers/base"
require "pathname"

module Sass
  module Sprockets
    class Importer < ::Sass::Importers::Base
      GLOB = /\*|\[.+\]/
      
      # Reference to the Sprockets context
      attr_reader :context
      
      # 
      def initialize(context)
        @context = context
      end
      
      # @see Sass::Importers::Base#find_relative
      def find_relative(path, base, options)
        unless base.to_s.empty?
          root_path = Pathname.new(context.root_path)
          base_path = Pathname.new(base).dirname
          path      = base_path.relative_path_from(root_path).join(path)
        end
        engine_from_path(path, options)
      end
      
      # @see Sass::Importers::Base#find
      def find(path, options)
        engine_from_path(path, options)
      end

      # @see Sass::Importers::Base#mtime
      def mtime(path, options)
        if logical_path = resolve(path)
          logical_path.mtime
        end
      rescue Errno::ENOENT
        nil
      end

      # @see Sass::Importers::Base#key
      def key(path, options)
        path = Pathname.new(path)
        ["#{self.class.name}:#{path.dirname.expand_path}", path.basename]
      end

      # @see Sass::Importers::Base#to_s
      def to_s
        "#{self.class.name}:#{context.pathname}"
      end
      
      protected
      
      # Create a Sass::Engine from the given path.
      # This is where all the magic happens!
      def engine_from_path(path, options)
        if logical_path = resolve(path)
          context.depend_on logical_path
          Sass::Engine.new context.evaluate(logical_path), options.merge(
            :filename => logical_path.to_s,
            :syntax   => :scss,
            :importer => self
          )
        end
      end
      
      # Finds an asset from the given path. This is where
      # we make Sprockets behave like Sass, and import partial
      # style paths.
      def resolve(path)
        path    = Pathname.new(path) unless path.is_a?(Pathname)
        partial = path.dirname.join("_#{path.basename}")
        
        resolve_asset(path) || resolve_asset(partial)
      end
      
      # Finds the asset using the context from Sprockets.
      def resolve_asset(logical_path)
        context.resolve(logical_path, :content_type => :self)
      rescue ::Sprockets::FileNotFound, ::Sprockets::ContentTypeMismatch
        nil
      end
    end
  end
end
