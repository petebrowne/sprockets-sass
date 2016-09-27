require 'spec_helper'

describe Sprockets::Sass do


  before :each do
    @root = create_construct
    @assets = @root.directory 'assets'
    @public_dir = @root.directory 'public'
    @env = Sprockets::Environment.new @root.to_s
    @env.append_path @assets.to_s
    @env.register_postprocessor 'text/css', FailPostProcessor
    @test_registration = Sprockets::Sass::TestRegistration.new(@env)
    @test_registration.register_engines('.xyz' =>  Sprockets::Sass::FakeEngine)
    @importer_class = Sprockets::Sass::Utils.get_class_by_version("Importer")
  end

  before(:each) do
    @assets.file 'main.css.scss', %(@import "dep")
    @dep_path = @assets.file 'dep.css.xyz', "$color: blue;\nbody { color: $color; }"
  end
  after :each do

    @root.destroy!
  end

  if (3...4).include?(Sprockets::Sass::Utils.version_of_sprockets)
    it 'allow calls the get engines from attributes with proper arguments' do
      expect_any_instance_of(@importer_class).to receive(:get_engines_from_attributes).with(anything, [@dep_path.to_s.gsub('.css.xyz', ''), "text/css", [".xyz"], nil]).at_least(:once).and_call_original
      asset = @env['main.css']
    end

    it 'calls the normalize extension from sprockets utils' do
      expect(::Sprockets::Utils).to receive(:normalize_extension).with('.xyz').at_least(:once).and_call_original
      asset = @env['main.css']
    end

    it 'retursn the engines registered on the file path' do
      expect_any_instance_of(@importer_class).to receive(:filter_all_processors).with(array_including(Sprockets::Sass::FakeEngine)).at_least(:once).and_call_original
      asset = @env['main.css']
    end
  end

end
