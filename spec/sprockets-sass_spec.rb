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
    @assets.file "application.css.scss", "//= require posts.css.scss"
    @assets.file "posts.css.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "processes sass files normally" do
    @assets.file "application.css.sass", "//= require posts.css.sass"
    @assets.file "posts.css.sass", ".post\n  color: blue"
    asset = @env["application.css.sass"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "imports standard files" do
    @assets.file "application.css.scss", '@import "posts"'
    @assets.file "posts.css.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "imports partial style files" do
    @assets.file "application.css.scss", '@import "posts"'
    @assets.file "_posts.css.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "imports relative files" do
    @assets.file "application/main.css.scss", '@import "./posts"'
    @assets.file "application/posts.css.scss", ".post { color: blue; }"
    asset = @env["application/main.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "imports files from the assets load path" do
    vendor = @root.directory "vendor"
    @env.append_path vendor.to_s
    
    @assets.file "application.css.scss", '@import "posts"'
    vendor.file "posts.css.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
  
  it "imports files from the Sass load path" do
    vendor = @root.directory "vendor"
    Sass::Engine::DEFAULT_OPTIONS[:load_paths] << vendor.to_s
    
    @assets.file "application.css.scss", '@import "posts"'
    vendor.file "posts.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end

  it "adds dependency when imported" do
    @assets.file "application.css.scss", '@import "posts"'
    dep = @assets.file "posts.css.scss", ".post { color: blue; }"
    
    asset = @env["application.css.scss"]
    asset.should be_fresh
    
    mtime = Time.now + 1
    dep.open("w") { |f| f.write ".post { color: red; }" }
    dep.utime mtime, mtime
    
    asset.should be_stale
  end
end
