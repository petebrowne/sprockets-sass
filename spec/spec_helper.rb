require 'rubygems'
require 'bundler/setup'
require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'compass'
require 'test_construct'

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec
  
  config.include RSpec::Matchers
  config.include TestConstruct::Helpers
end

Compass.configuration do |compass|
  compass.line_comments = false
  compass.output_style  = :nested
end
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


def compile_asset_and_return_compilation(env, public_dir, filename )
  if Sprockets::Sass::Utils.version_of_sprockets < 3
    manifest = Sprockets::Manifest.new(env, public_dir)
  else
    manifest = Sprockets::Manifest.new(env, public_dir, File.join(public_dir ,'manifest.json'))
  end
  manifest.compile(filename)
  res = File.read(File.join(public_dir, manifest.files.keys.first))
  manifest.clobber
  res
end

def write_asset(filename, contents, mtime = nil)
  mtime ||= [Time.now.to_i, File.stat(filename).mtime.to_i].max + 1
  File.open(filename, 'w') do |f|
    f.write(contents)
  end
  if Sprockets::Sass::Utils.version_of_sprockets >= 3
    File.utime(mtime, mtime, filename)
  else
    mtime = Time.now + 1
    filename.utime mtime, mtime
  end
end
