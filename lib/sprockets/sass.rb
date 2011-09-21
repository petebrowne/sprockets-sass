require "sprockets/sass/version"
require "sprockets/sass/sass_template"
require "sprockets/sass/scss_template"
require "sprockets/engines"

module Sprockets
  module Sass
    autoload :Importer, "sprockets/sass/importer"
    
    ::Sprockets.register_engine ".sass", SassTemplate
    ::Sprockets.register_engine ".scss", ScssTemplate
  end
end
