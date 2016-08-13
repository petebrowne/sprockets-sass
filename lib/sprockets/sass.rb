# frozen_string_literal: true
require 'sprockets'
require 'sprockets/sass/version'
require 'sprockets/sass/utils'
require 'sprockets/sass/registration'
require 'sass'
require 'sass/importers/base'

require 'json'
require 'pathname'


# the module of Sprockets
module Sprockets
  # The internal Sass module used to load and acessing configuration
  module Sass
    class << self
      # Global configuration for `Sass::Engine` instances.
      attr_accessor :options

      # When false, the asset path helpers provided by
      # sprockets-helpers will not be added as Sass functions.
      # `true` by default.
      attr_accessor :add_sass_functions
    end

    @options = {}
    @add_sass_functions = true
  end

  begin
    require 'sprockets/directive_processor'
    require 'sprockets/sass_processor'
    require 'sprockets/sassc_processor'
    require 'sprockets/digest_utils'
    require 'sprockets/engines'
  rescue LoadError; end

  if Sprockets::Sass::Utils.version_of_sprockets >= 3
    # We need this only for Sprockets > 3 in order to be able to register anything.
    # For Sprockets 2.x , although the file and the module name exist,
    # they can't be used because it will give errors about undefined methods, because this is included only on Sprockets::Base
    # and in order to use them we would have to subclass it and define methods to expire cache and other methods for registration ,
    # which are not needed since Sprockets already  knows about that using the environment instead internally
    require 'sprockets/processing'
    extend Sprockets::Processing
  end

  registration = Sprockets::Sass::Registration.new(self)
  registration.run
end

# Sprockets 4 needs this , becasue it doesnt use ::Sass in code, which results in a conflict with this gem :(
Sprockets::Sass::Importers = ::Sass::Importers
