require "spec_helper"

describe Sass::Sprockets do
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
    asset.dependencies.should == [ @env["posts.css.scss"] ]
  end
  
  it "processes sass files normally" do
    @assets.file "application.css.sass", "//= require posts.css.sass"
    @assets.file "posts.css.sass", ".post\n  color: blue"
    asset = @env["application.css.sass"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
    asset.dependencies.should == [ @env["posts.css.sass"] ]
  end
  
  it "finds imported files" do
    @assets.file "application.css.scss", '@import "posts"'
    @assets.file "posts.css.scss", ".post { color: blue; }"
    asset = @env["application.css.scss"]
    asset.to_s.should == ".post {\n  color: blue; }\n"
  end
end
