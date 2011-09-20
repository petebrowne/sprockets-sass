require "sass/sprockets/version"
require "sass/sprockets/sass_template"
require "sass/sprockets/scss_template"
require "sprockets/engines"

module Sass
  module Sprockets
    autoload :Importer, "sass/sprockets/importer"
    
    ::Sprockets.register_engine ".sass", SassTemplate
    ::Sprockets.register_engine ".scss", ScssTemplate
  end
end
