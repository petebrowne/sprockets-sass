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
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "processes sass files normally" do
    @assets.file "main.css.sass", "//= require dep"
    @assets.file "dep.css.sass", "body\n  color: blue"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports standard files" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.css.scss", "$color: blue;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports partial style files" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "_dep.css.scss", "$color: blue;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports other syntax" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.sass", "$color: blue\nhtml\n  height: 100%"
    asset = @env["main.css"]
    asset.to_s.should == "html {\n  height: 100%; }\n\nbody {\n  color: blue; }\n"
  end
  
  it "imports files with directives" do
    @assets.file "main.css.scss", %(@import "dep";)
    @assets.file "dep.css", "/*\n *= require subdep\n */"
    @assets.file "subdep.css.scss", "$color: blue;\nbody { color: $color; }"
    asset = @env["main.css"]
    asset.to_s.should include("body {\n  color: blue; }\n")
  end
  
  it "imports files with additional processors" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.css.scss.erb", "$color: <%= 'blue' %>;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports relative files" do
    @assets.file "folder/main.css.scss", %(@import "./dep";\nbody { color: $color; })
    @assets.file "folder/dep.css.scss", "$color: blue;"
    asset = @env["folder/main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files relative to root" do
    @assets.file "folder/main.css.scss", %(@import "dep";\nbody { color: $color; })
    @assets.file "dep.css.scss", "$color: blue;"
    asset = @env["folder/main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "shares Sass environment with other imports" do
    @assets.file "main.css.scss", %(@import "dep1";\n@import "dep2";)
    @assets.file "_dep1.scss", "$color: blue;"
    @assets.file "_dep2.scss", "body { color: $color; }"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files from the assets load path" do
    vendor = @root.directory "vendor"
    @env.append_path vendor.to_s
    
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    vendor.file "dep.css.scss", "$color: blue;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports files from the Sass load path" do
    vendor = @root.directory "vendor"
    Sass::Engine::DEFAULT_OPTIONS[:load_paths] << vendor.to_s
    
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    vendor.file "dep.scss", "$color: blue;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue; }\n"
  end
  
  it "imports globbed files" do
    @assets.file "main.css.scss", %(@import "folder/*";\nbody { color: $color; background: $bg-color; })
    @assets.file "folder/dep1.css.scss", "$color: blue;"
    @assets.file "folder/dep2.css.scss", "$bg-color: red;"
    asset = @env["main.css"]
    asset.to_s.should == "body {\n  color: blue;\n  background: red; }\n"
  end

  it "adds dependencies when imported" do
    @assets.file "main.css.scss", %(@import "dep";\nbody { color: $color; })
    dep = @assets.file "dep.css.scss", "$color: blue;"
    
    asset = @env["main.css"]
    asset.should be_fresh
    
    mtime = Time.now + 1
    dep.open("w") { |f| f.write "$color: red;" }
    dep.utime mtime, mtime
    
    asset.should be_stale
  end

  it "adds dependencies from assets when imported" do
    @assets.file "main.css.scss", %(@import "dep1";\nbody { color: $color; })
    @assets.file "dep1.css.scss", %(@import "dep2";\n)
    dep = @assets.file "dep2.css.scss", "$color: blue;"
    
    asset = @env["main.css"]
    asset.should be_fresh
    
    mtime = Time.now + 1
    dep.open("w") { |f| f.write "$color: red;" }
    dep.utime mtime, mtime
    
    asset.should be_stale
  end

  it "adds dependencies when imported from a glob" do
    @assets.file "main.css.scss", %(@import "folder/*";\nbody { color: $color; background: $bg-color; })
    @assets.file "folder/_dep1.scss", "$color: blue;"
    dep = @assets.file "folder/_dep2.scss", "$bg-color: red;"
    
    asset = @env["main.css"]
    asset.should be_fresh
    
    mtime = Time.now + 1
    dep.open("w") { |f| f.write "$bg-color: white;" }
    dep.utime mtime, mtime
    
    asset.should be_stale
  end
end
