## Requirements ##

You must use Ruby 1.8.7. [Ruby Enterprise
Edition](http://www.rubyenterpriseedition.com/) is recommended. To really do
things right, you should be using [RVM](http://rvm.io/).

Before you begin, run `sudo apt-get install coffeescript`

You'll also need to downgrade to RubyGems 1.8 for this to work: http://stackoverflow.com/questions/15349869/undefined-method-source-index-for-gemmodule-nomethoderror

## Installing ##

### Recommended ###

    git clone https://github.com/justinforce/deezy
    cd deezy
    rvm --install --create --rvmrc ree@deezy
    rvm rubygems latest-1.8
    cd .
    bundle

### Without RVM ###

    git clone https://github.com/justinforce/deezy
    cd deezy
    bundle

## Configuration ##

Configure your database in the usual Rails way, then

    rake js # This will fail if you don't have coffeescript installed from the repos
    rake db:setup
    rake db:migrate

Configure a `deezy.yml` file. There's a sample with comments in the config directory.

## Running ##

    script/server

There are also sample nginx and unicorn upstart and config files in the config directory.

## Rake tasks ##

The most important one is `rake js` which will build the production JavaScript
from the CoffeeScript source and then minify everything. See `rake -T coffee`
and `rake -T js` for more information.

## Copyright ##

Copyright 2012 by Justin Force

Licensed under the [MIT license](http://www.opensource.org/licenses/MIT)