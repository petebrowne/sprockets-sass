require "sass"
require "sprockets-helpers"

module Sprockets
  module Sass
    module Functions
      # Using Sprockets::Helpers#asset_path, return the full path
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: url(asset-path("image.jpg"));                // background: url("/assets/image.jpg");
      #   background: url(asset-path("image.jpg", $digest: true)); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def asset_path(source, options = {})
        ::Sass::Script::String.new context.asset_path(source.value, map_options(options)), :string
      end
      
      # Using Sprockets::Helpers#asset_path, return the url CSS
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: asset-url("image.jpg");                // background: url("/assets/image.jpg");
      #   background: asset-url("image.jpg", $digest: true); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def asset_url(source, options = {})
        ::Sass::Script::String.new "url(#{asset_path(source, options)})"
      end
      
      # Using Sprockets::Helpers#image_path, return the full path
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: url(image-path("image.jpg"));                // background: url("/assets/image.jpg");
      #   background: url(image-path("image.jpg", $digest: true)); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def image_path(source, options = {})
        ::Sass::Script::String.new context.image_path(source.value, map_options(options)), :string
      end
      
      # Using Sprockets::Helpers#image_path, return the url CSS
      # for the given +source+ as a Sass String. This supports keyword
      # arguments that mirror the +options+.
      #
      # === Examples
      #
      #   background: asset-url("image.jpg");                // background: url("/assets/image.jpg");
      #   background: asset-url("image.jpg", $digest: true); // background: url("/assets/image-27a8f1f96afd8d4c67a59eb9447f45bd.jpg");
      #
      def image_url(source, options = {}, cache_buster = nil)
        # Check for the Compass #image_url API,
        # and work with it. We don't want to break
        # the Compass mixins that expect it.
        if options.respond_to? :value
          case options.value
          when true
            return image_path source
          else
            options = {}
          end
        end
        ::Sass::Script::String.new "url(#{image_path(source, options)})"
      end
      
      protected
      
      # Returns a reference to the Sprocket's context through
      # the importer.
      def context # :nodoc:
        options[:importer].context
      end
      
      # Returns an options hash where the keys are symbolized
      # and the values are unwrapped Sass literals.
      def map_options(options = {}) # :nodoc:
        ::Sass::Util.map_hash(options) do |key, value|
          [key.to_sym, value.respond_to?(:value) ? value.value : value]
        end
      end
    end
  end
end

module Sass::Script::Functions
  include Sprockets::Sass::Functions
  
  # Hack to ensure the Compass API signatures don't take precedence
  @signatures[:image_url] = []
  
  declare :asset_path, [:source], :var_kwargs => true
  declare :asset_url,  [:source], :var_kwargs => true
  declare :image_path, [:source], :var_kwargs => true
  declare :image_url,  [:source], :var_kwargs => true, :var_args => true
end
