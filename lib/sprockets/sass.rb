require "sprockets/sass/version"
require "sprockets/sass/sass_template"
require "sprockets/sass/scss_template"
require "sprockets/engines"

module Sprockets
  module Sass
    autoload :Importer, "sprockets/sass/importer"
  end
    
  register_engine ".sass", Sass::SassTemplate
  register_engine ".scss", Sass::ScssTemplate
end
