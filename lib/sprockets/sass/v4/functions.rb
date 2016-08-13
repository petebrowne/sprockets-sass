# frozen_string_literal: true
require_relative '../v3/functions'
module Sprockets
  module Sass
    module V4
      # Module used to inject helpers into SASS engine
      module Functions
        include Sprockets::Sass::V3::Functions
      end
    end
  end
end
