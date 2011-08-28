namespace :js do
  desc "Minify javascript src for production environment"
  task :min => :environment do
    # list of files to minify
    libs = ['public/deezy/javascripts/prototype.js', 
            'public/deezy/javascripts/effects.js', 
            'public/deezy/javascripts/application.js']

    # paths to jsmin script and final minified file
    jsmin = 'script/javascript/jsmin.rb'
    final = 'public/deezy/javascripts/all_min.js'

    # create single tmp js file
    tmp = Tempfile.open('all')
    libs.each {|lib| open(lib) {|f| tmp.write(f.read) } }
    tmp.rewind

    # minify file
    %x[ruby #{jsmin} < #{tmp.path} > #{final}]
    puts "\n#{final}"
  end
end

