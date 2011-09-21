Sprockets::Sass
===============

**Sprockets::Sass is a gem that fixes `@import` when used within Sprockets + Sass projects.**

This is currently fixed in Rails 3.1, when using the [sass-rails gem](https://github.com/rails/sass-rails). But if you want to use Sprockets and Sass anywhere else, like Sinatra, use Sprockets::Sass.

### `@import` Features

* Imports Sass _partials_ (filenames prepended with "_").
* Import paths work exactly like `require` directives*.
* Imports either Sass syntax, or just regular CSS files.
* Imported files are preprocessed by Sprockets, so `.css.scss.erb` files can be imported.
  Directives from within imported files also work as expected.
* Standard Sass load paths are not touched, so Compass extensions will work as expected.

_* Glob support coming in 0.2.0_

Installation
------------

``` bash
$ gem install sprockets-sass
```

Usage
-----

In your Rack application, setup Sprockets as you normally would, and require "sprockets-sass":

``` ruby
require "sprockets"
require "sprockets-sass"
require "sass"

map "/assets" do
  environment = Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  run environment
end

map "/" do
  run YourRackApp
end
```

Now `@import` works essentially just like a `require` directive, but with one essential bonus:
Sass mixins, variables, etc. work as expected.

Given the following Sass _partials_:

``` scss
// assets/stylesheets/_mixins.scss
@mixin border-radius($radius) {
  -webkit-border-radius: $radius;
  -moz-border-radius: $radius;
  border-radius: $radius;
}
```

``` scss
// assets/stylesheets/_settings.scss
$color: red;
```

In another file - you can now do this - from within a Sprockets asset:

``` scss
// assets/stylesheets/application.css.scss
@import "mixins";
@import "settings";

button {
  @include border-radius(5px);
  color: $color;
}
```

And `GET /assets/application.css` would return something like:

``` css
button {
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 5px;
  color: red; }
```

Copyright
---------

Copyright (c) 2011 [Peter Browne](http://petebrowne.com). See LICENSE for details.
