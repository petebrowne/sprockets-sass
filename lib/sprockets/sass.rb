require "sprockets/sass/version"
require "sprockets/sass/sass_template"
require "sprockets/sass/scss_template"
require "sprockets/engines"

module Sprockets
  module Sass
    autoload :Importer, "sprockets/sass/importer"
    
    # Global configuration for `Sass::Engine` instances.
    def self.options
      @options ||= {}
    end
  end
    
  register_engine ".sass", Sass::SassTemplate
  register_engine ".scss", Sass::ScssTemplate
end
