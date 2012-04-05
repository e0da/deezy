fs = require 'fs'

SRC = 'app/assets/javascripts'
LIB = 'public/deezy/javascripts'

{print} = require 'sys'
{spawn, exec} = require 'child_process'

dist_files = [
  'background.html'
  'popout.html'
  'popout_for_youtube.css'
  'images'
  'lib'
  'vendor'
  '_locales'
  'manifest.json'
  'README.md'
  'LICENSE'
].join ' '

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
