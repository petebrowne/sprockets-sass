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
    
    # Adds the Sass functions if the
    # sprockets-helpers gem is available.
    def self.load_sass_functions
      begin
        require "sprockets/sass/functions"
      rescue LoadError
        return false
      end
      
      true
    end
  end
  
  # Register the new templates
  register_engine ".sass", Sass::SassTemplate
  register_engine ".scss", Sass::ScssTemplate
  
  # Attempt to load the Sass functions
  Sass.load_sass_functions
end
