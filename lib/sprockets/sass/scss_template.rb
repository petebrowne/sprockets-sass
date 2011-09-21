module Sprockets
  module Sass
    class ScssTemplate < SassTemplate
      # Define the expected syntax for the template
      def syntax
        :scss
      end
    end
  end
end
