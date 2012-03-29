desc "Compiles all js.coffee files from app/assets/javascripts to a single file public/javascripts/application.js"
task :build_application_js => :environment do
  require 'coffee_script'
  puts "..."
  puts "Building application.js"
  
  output_file_path = "./public/deezy/javascripts/application.js"
  source_directory_path = "./app/assets/javascripts"
  content = "// DO NOT MODIFY this file, auto-generated from all js.coffee files in #{source_directory_path}\n\n"
    
  Dir.glob("#{source_directory_path}/*.js.coffee").each do |file|
    puts "  - compile #{file}"
    compiled = CoffeeScript.compile File.read(file)
    content = content + "// compiled #{file} \n#{compiled}\n"
  end
  
  File.open(output_file_path, "w") { |file| file << content }

  puts "  Rewrote #{output_file_path}"
  puts "Done building application.js"
end
