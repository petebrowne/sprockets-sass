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
  
  # Register the new templates
  register_engine ".sass", Sass::SassTemplate
  register_engine ".scss", Sass::ScssTemplate
  
  # Attempt to add the Sass Functions
  begin
    require "sass"
    require "sprockets/sass/functions"
  rescue LoadError
    # fail silently...
  end
end


