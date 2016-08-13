# frozen_string_literal: true
require_relative '../v3/sass_template'
module Sprockets
  module Sass
    module V4
      # Preprocessor for SASS files
      class SassTemplate < Sprockets::Sass::V3::SassTemplate
        # This is removed
        # def self.default_mime_type
        #   "text/#{syntax}"
        # end
        #
        def self.syntax
          :sass
        end

        def custom_cache_store(*args)
          Sprockets::Sass::V4::CacheStore.new(*args)
        end

        def custom_importer_class(*_args)
          Sprockets::Sass::V4::Importer.new
        end
      end
    end
  end
end
