# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sass/sprockets/version"

Gem::Specification.new do |s|
  s.name        = "sass-sprockets"
  s.version     = Sass::Sprockets::VERSION
  s.authors     = ["Pete Browne"]
  s.email       = ["me@petebrowne.com"]
  s.homepage    = "http://github.com/petebrowne/sass-sprockets"
  s.summary     = %q{Better Sass integration with Sprockets 2.0}
  s.description = %q{Sass::Sprockets is a gem that fixes @import when used within Sprockets + Sass projects.}

  s.rubyforge_project = "sass-sprockets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "sprockets", "~> 2.0"
  s.add_dependency "tilt", "~> 1.3"
  s.add_dependency "sass", "~> 3.1"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "test-construct", "~> 1.2"
end
