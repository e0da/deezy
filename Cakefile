fs            = require 'fs'
{print}       = require 'sys'
{spawn, exec} = require 'child_process'

SRC = 'app/views/scripts'
LIB = 'public/javascripts'

build = (watch=false) ->
  options = ['-w', '-c', '-o', LIB, SRC]
  options.shift '-w' unless watch
  coffee = spawn 'coffee', options
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'build', "build all CoffeeScript in #{SRC} to JavaScript in #{LIB}", ->
  build()
task 'watch', "watch for changes to CoffeeScript in #{SRC} and build to JavaScript in #{LIB}", ->
  build true
