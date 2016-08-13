# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'sprockets/sass/version'

Gem::Specification.new do |s|
  s.name        = 'sprockets-sass'
  s.version     = Sprockets::Sass::VERSION
  s.authors     = ['Pete Browne']
  s.email       = ['me@petebrowne.com']
  s.homepage    = 'http://github.com/petebrowne/sprockets-sass'
  s.summary     = 'Better Sass integration with Sprockets 2.0'
  s.description = "When using Sprockets 2.0 with Sass you will eventually run into a pretty big issue. `//= require` directives will not allow Sass mixins, variables, etc. to be shared between files. So you'll try to use `@import`, and that'll also blow up in your face. `sprockets-sass` fixes all of this by creating a Sass::Importer that is Sprockets aware."

  s.rubyforge_project = 'sprockets-sass'

  # usually the license needs to be specified in gemspec also as a standard
  s.licenses = ['MIT']

  # This is needed so that on rubygems.org we can see the actual date
  # of the published version due to changes in Rubygems repo over the last year(2015 - 2016)
  s.date = Date.today

  # usually the platform needs to be specified also, to avoid people trying to install this gem on wrong platform
  s.platform = Gem::Platform::RUBY

  s.required_ruby_version = '>= 2.0'
  s.required_rubygems_version = '>= 2.0'
  s.metadata = {
    'source_url' => s.homepage,
    'issue_tracker' => "#{s.homepage}/issues"
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split('\n').map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency             'sprockets',         '>= 2.0', '< 4.0'

  s.add_development_dependency 'rspec',             '~> 2.13'
  s.add_development_dependency 'test_construct',    '~> 2.0'
  s.add_development_dependency 'sprockets-helpers', '~> 1.0'
  s.add_development_dependency 'sass',              '~> 3.3'
  s.add_development_dependency 'compass',           '~> 1.0.0.alpha.19'
  s.add_development_dependency 'pry'

  s.add_development_dependency 'appraisal', '~> 2.1', '>= 2.1'
  s.add_development_dependency 'rake', '>= 10.5', '>= 10.5'
end
