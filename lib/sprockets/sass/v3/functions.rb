# frozen_string_literal: true
require_relative '../v2/functions'
module Sprockets
  module Sass
    module V3
      # Module used to inject helpers into SASS engine
      module Functions
        include Sprockets::Sass::V2::Functions
      end
    end
  end
end
