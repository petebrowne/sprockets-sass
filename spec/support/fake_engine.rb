module Sprockets
  module Sass
    class FakeEngine
      VERSION = '1'

      def self.default_mime_type
        'text/xyx'
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

      attr_accessor :has_been_used
      attr_reader :context

      def initialize(*_args, &block)
        @has_been_used = false
      end

      def call(input)
        @context  = input[:environment].context_class.new(input)
        run
      end

      def render(context, _empty_hash_wtf)
        @context = context
        run
      end

      def run
        @has_been_used = true
        result = ""
        if context.respond_to?(:metadata)
          context.metadata.merge(data: result, sass_dependencies:  Set.new([]))
        else
          result
        end
      end

    end
  end
end
