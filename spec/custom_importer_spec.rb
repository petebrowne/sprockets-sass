require 'spec_helper'

describe Sprockets::Sass::SassTemplate do

  before :each do
    # Create the custom importer.
    @custom_importer =  Sprockets::Sass::DummyImporter.new
    Sprockets::Sass.options[:importer] = @custom_importer

    # Initialize the environment.
    @root = create_construct
    @assets = @root.directory 'assets'
    @env = Sprockets::Environment.new @root.to_s
    @env.append_path @assets.to_s
    @env.register_postprocessor 'text/css', FailPostProcessor
  end

  after :each do
    @root.destroy!
    #Sprockets::Sass.options[:importer] = nil
  end

  it 'allow specifying custom sass importer' do
    @assets.file 'main.css.scss', %(@import "dep")
    @assets.file 'dep.css.scss', "$color: blue;\nbody { color: $color; }"
    asset = @env['main.css']
    expect(@custom_importer.has_been_used).to be_truthy
  end

end
