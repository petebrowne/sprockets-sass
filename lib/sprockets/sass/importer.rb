require "sass/importers/base"
require "pathname"

module Sprockets
  module Sass
    class Importer < ::Sass::Importers::Base
      # Reference to the Sprockets context
      attr_reader :context
      
      # 
      def initialize(context)
        @context = context
      end
      
      # @see Sass::Importers::Base#find_relative
      def find_relative(path, base, options)
        engine_from_path(path, options)
      end
      
      # @see Sass::Importers::Base#find
      def find(path, options)
        engine_from_path(path, options)
      end

      # @see Sass::Importers::Base#mtime
      def mtime(path, options)
        if pathname = resolve(path)
          pathname.mtime
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
        pathname = resolve(path) or return nil
        context.depend_on pathname
        ::Sass::Engine.new evaluate(pathname), options.merge(
          :filename => pathname.to_s,
          :syntax   => syntax(pathname),
          :importer => self
        )
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
      def resolve_asset(path)
        context.resolve(path, :content_type => :self)
      rescue ::Sprockets::FileNotFound, ::Sprockets::ContentTypeMismatch
        nil
      end
      
      # Returns the Sass syntax of the given path.
      def syntax(path)
        path.to_s.include?(".sass") ? :sass : :scss
      end
      
      # Returns the string to be passed to the Sass engine. We use
      # Sprockets to process the file, but we remove any Sass processors
      # because we need to let the Sass::Engine handle that.
      def evaluate(path)
        processors = context.environment.attributes_for(path).processors.dup
        processors.delete_if { |processor| processor < Tilt::SassTemplate }
        context.evaluate path, :processors => processors
      end
    end
  end
end
