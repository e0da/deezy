desc 'Alias for coffee:build'
task :coffee => :'coffee:build'

namespace :coffee do

  def cake
    @cake ||= `which cake.coffeescript`
    @cake ||= `which cake`
    @cake ||= 'cake'
    @cake.chomp!
    puts "Using #{@cake} for cake"
    @cake
  end


  desc 'Compile CoffeeScript to JavaScript'
  task :build do
    `#{cake} build`
  end

  desc 'Rebuild JavaScript as CoffeeScript changes'
  task :watch do
    `#{cake} watch`
  end
end
