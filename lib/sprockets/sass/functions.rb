require "sass"
require "sprockets-helpers"

module Sass
  module Script
    module Functions
      #
      def asset_path(source, options = {})
        Script::String.new context.asset_path(source.value, map_options(options)), :string
      end
      declare :asset_path, [:source], :var_kwargs => true
      
      #
      def asset_url(source, options = {})
        Script::String.new "url(#{asset_path(source, options)})"
      end
      declare :asset_url, [:source], :var_kwargs => true
      
      #
      def image_path(source, options = {})
        Script::String.new context.image_path(source.value, map_options(options)), :string
      end
      declare :image_path, [:source], :var_kwargs => true
      
      #
      def image_url(source, options = {})
        Script::String.new "url(#{image_path(source, options)})"
      end
      declare :image_url, [:source], :var_kwargs => true
      
      protected
      
      # Returns a reference to the Sprocket's context through
      # the importer.
      def context # :nodoc:
        options[:importer].context
      end
      
      # Returns an options hash where the keys are symbolized
      # and the values are unwrapped Sass literals.
      def map_options(options = {})
        Sass::Util.map_hash(options) do |key, value|
          [key.to_sym, value.respond_to?(:value) ? value.value : value]
        end
      end
    end
  end
end
