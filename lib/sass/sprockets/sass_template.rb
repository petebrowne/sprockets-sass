require "tilt"

module Sass
  module Sprockets
    class SassTemplate < Tilt::SassTemplate
      attr_reader :scope
      
      # Define the expected syntax for the template
      def syntax
        :sass
      end
      
      def prepare
        @scope  = nil
        @output = nil
      end
      
      def evaluate(scope, locals, &block)
        @output ||= begin
          @scope = scope
          Sass::Engine.new(data, sass_options).render
        end
      end

      private
      
      def sass_options
        options.merge(
          :filename            => eval_file,
          :line                => line,
          :syntax              => syntax,
          :load_paths          => load_paths,
          :filesystem_importer => Importer
        )
      end
      
      def load_paths
        load_paths = (options[:load_paths] || []).dup
        load_paths.unshift(*scope.environment.paths) if scope.respond_to? :environment
        load_paths
      end
    end
  end
end
