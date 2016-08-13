# frozen_string_literal: true
require_relative './sass_template'
module Sprockets
  module Sass
    module V3
      # Preprocessor for SCSS files
      class ScssTemplate < Sprockets::Sass::V3::SassTemplate
        # Define the expected syntax for the template
        def self.syntax
          :scss
        end
      end
    end
  end
end
