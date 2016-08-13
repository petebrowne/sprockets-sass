# frozen_string_literal: true
module Sprockets
  module Sass
    module V2
      # Class used to compress CSS files
      class Compressor
        def self.instance
          @instance ||= new
        end

        def self.compress(input)
          instance.compress(input)
        end

        # Compresses the given CSS using Sass::Engine's
        # :compressed output style.
        def compress(css)
          if css.count("\n") >= 2
            ::Sass::Engine.new(css,
                               syntax: :scss,
                               cache: false,
                               read_cache: false,
                               style: :compressed).render
          else
            css
          end
        end
      end
    end
  end
end
