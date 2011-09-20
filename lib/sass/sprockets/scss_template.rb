module Sass
  module Sprockets
    class ScssTemplate < SassTemplate
      # Define the expected syntax for the template
      def syntax
        :scss
      end
    end
  end
end
