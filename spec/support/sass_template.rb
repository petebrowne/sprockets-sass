module Sprockets
  module Sass
    class SassTemplate < Sprockets::Sass::Utils.get_class_by_version("SassTemplate")

      def initialize(*args, &block)
        super(*args, &block)
      end

    end
  end
end
