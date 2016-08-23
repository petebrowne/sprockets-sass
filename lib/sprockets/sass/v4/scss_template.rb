# frozen_string_literal: true
require_relative './sass_template'

# @TODO refactor the Sprockets::Sass::Functions , logical_path is unavailable
module Sprockets
  module Sass
    module V4
      # Preprocessor for SCSS files
      class ScssTemplate < Sprockets::Sass::V4::SassTemplate
        def self.syntax
          :scss
        end
      end
    end
  end
end
