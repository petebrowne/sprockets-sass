require "sass"

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
        # Check for the Sass::Rails' #asset_path API,
        # and work with it. We want to make Rails assets work
        # just fine with Machined.
        if options.respond_to? :value
          kind = options.value
          options = {}
        end
        
        if kind && context.respond_to?("#{kind}_path")
          ::Sass::Script::String.new context.send("#{kind}_path", source.value), :string
        else
          ::Sass::Script::String.new context.asset_path(source.value, map_options(options)), :string
        end
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
      
      # Using Sprockets::Context#asset_data_uri return a Base64-encoded `data:`
      # URI with the contents of the asset at the specified path.
      #
      # === Examples
      # 
      #   background: asset-data-uri("image.jpg"); // background: url(data:image/jpeg;base64,...);
      #
      def asset_data_uri(source)
        ::Sass::Script::String.new "url(#{context.asset_data_uri(source.value)})"
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
  
  # Hack to ensure previous API declarations (by Compass or whatever)
  # don't take precedence.
  [:asset_path, :asset_url, :image_path, :image_url, :asset_data_uri].each do |method|
    defined?(@signatures) && @signatures.delete(method)
  end
  
  declare :asset_path,     [:source], :var_kwargs => true
  declare :asset_path,     [:source, :kind]
  declare :asset_url,      [:source], :var_kwargs => true
  declare :asset_url,      [:source, :kind]
  declare :image_path,     [:source], :var_kwargs => true
  declare :image_url,      [:source], :var_kwargs => true
  declare :image_url,      [:source, :only_path]
  declare :image_url,      [:source, :only_path, :cache_buster]
  declare :asset_data_uri, [:source]
end
