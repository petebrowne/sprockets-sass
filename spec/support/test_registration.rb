module Sprockets
  module Sass
    class TestRegistration < Sprockets::Sass::Registration

      def register_engines(hash)
        _register_engines(hash)
      end

    end
  end
end
