require 'jsmin'

desc 'Prepare JavaScript by compiling CoffeeScript then minimizing the output'
task :js => [ :coffee, :'js:min' ]

namespace :js do

  desc 'Minify JavaScript'
  task :min do

    # list of files to minify IN ORDER
    files = [
      'public/deezy/javascripts/jquery.min.js', 
      'public/deezy/javascripts/application.js'
    ]

    # paths to minified file
    min = 'public/deezy/javascripts/all_min.js'

    # read all of the JavaScript into a string then minify it
    js = files.inject('') do |str, src|
      open(src) { |sf| str << sf.read }
    end
    open(min, 'w') { |f| f.write JSMin.minify(js) }
  end
end
