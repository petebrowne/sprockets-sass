# frozen_string_literal: true
module Sprockets
  module Sass
    module V2
      # Preprocessor for SCSS files
      class ScssTemplate < Sprockets::Sass::V2::SassTemplate
        # Define the expected syntax for the template
        def self.syntax
          :scss
        end
      end
    end
  end
end
