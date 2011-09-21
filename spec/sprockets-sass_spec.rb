require "spec_helper"

describe Sprockets::Sass do
  before :each do
    @root   = create_construct
    @assets = @root.directory "assets"
    @env    = Sprockets::Environment.new @root.to_s
    @env.append_path @assets.to_s
  end
  
  after :each do
    @root.destroy!
  end
  
  it "processes scss files normally" do
    @assets.file "main.css.scss", "//= require dep"
    @assets.file "dep.css.scss", "body { color: blue; }"
    asset = @env["main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "processes sass files normally" do
    @assets.file "main.css.sass", "//= require dep"
    @assets.file "dep.css.sass", "body\n  color: blue"
    asset = @env["main.css.sass"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports standard files" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.css.scss", "$color: blue;"
    asset = @env["main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports partial style files" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "_dep.css.scss", "$color: blue;"
    asset = @env["main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports relative files" do
    @assets.file "folder/main.css.scss", %(@import "./dep";\nbody { color: $color; })
    @assets.file "folder/dep.css.scss", "$color: blue;"
    asset = @env["folder/main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files relative to root" do
    @assets.file "folder/main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.css.scss", "$color: blue;"
    asset = @env["folder/main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files from the assets load path" do
    vendor = @root.directory "vendor"
    @env.append_path vendor.to_s
    
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    vendor.file "dep.css.scss", "$color: blue;"
    asset = @env["main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files from the Sass load path" do
    vendor = @root.directory "vendor"
    Sass::Engine::DEFAULT_OPTIONS[:load_paths] << vendor.to_s
    
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    vendor.file "dep.scss", "$color: blue;"
    asset = @env["main.css.scss"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end

  it "adds dependency when imported" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    dep = @assets.file "dep.css.scss", "$color: blue;"
    
    asset = @env["main.css.scss"]
    asset.should be_fresh
    
    mtime = Time.now + 1
    dep.open("w") { |f| f.write "$color: red;" }
    dep.utime mtime, mtime
    
    asset.should be_stale
  end
end
