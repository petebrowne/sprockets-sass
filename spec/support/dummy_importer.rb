module Sprockets
  module Sass

    class DummyImporter < Sprockets::Sass::Utils.get_class_by_version("Importer")
      attr_accessor :has_been_used

      def initialize
        super()
        @has_been_used = false
      end

      def find(path, options)
        @has_been_used = true
        super(path, options)
      end

      def find_relative(uri, base, options, *args)
        @has_been_used = true
        super(uri, base, options, *args)
      end

    end

  end
end
