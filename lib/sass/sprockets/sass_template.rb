require "tilt"

module Sass
  module Sprockets
    class SassTemplate < Tilt::SassTemplate
      
      # A reference to the current Sprockets context
      attr_reader :context
      
      # Define the expected syntax for the template
      def syntax
        :sass
      end
      
      def prepare
        @context = nil
        @output  = nil
      end
      
      def evaluate(context, locals, &block)
        @output ||= begin
          @context = context
          Sass::Engine.new(data, sass_options).render
        end
      end

      private
      
      def sass_options
        options.merge(
          :filename => eval_file,
          :line     => line,
          :syntax   => syntax,
          :importer => importer
        )
      end
      
      def importer
        Sass::Sprockets::Importer.new context
      end
    end
  end
end
