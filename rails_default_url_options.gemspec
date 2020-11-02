## rails_default_url_options.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "rails_default_url_options"
  spec.version = "8.0.1"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "rails_default_url_options"
  spec.description = "description: rails_default_url_options kicks the ass"
  spec.license = "Ruby"

  spec.files =
["README.md",
 "Rakefile",
 "lib",
 "lib/rails_default_url_options",
 "lib/rails_default_url_options.rb",
 "lib/rails_default_url_options/_lib.rb",
 "rails_default_url_options.gemspec"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["rails", " ~> 6.0"])
  
    spec.add_dependency(*["map", " ~> 6.6"])
  
    spec.add_dependency(*["fattr", " ~> 2.4"])
  
    spec.add_dependency(*["tagz", " ~> 9.10"])
  
    spec.add_dependency(*["rails_current", " ~> 2.2"])
  

  spec.extensions.push(*[])

  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/rails_default_url_options"
end
