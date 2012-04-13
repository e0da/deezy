## Requirements ##

You must use Ruby 1.8.7. [Ruby Enterprise
Edition](http://www.rubyenterpriseedition.com/) is recommended. To really do
things right, you should be using [RVM](http://rvm.io/).

## Installing ##

### Recommended ###

    git clone https://github.com/justinforce/deezy
    cd deezy
    rvm --install --create --rvmrc ree@deezy
    cd .
    bundle

### Without RVM ###

    git clone https://github.com/justinforce/deezy
    cd deezy
    bundle

## Configuration ##

Configure your database in the usual Rails way, then

    rake js
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
