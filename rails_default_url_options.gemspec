## rails_default_url_options.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "rails_default_url_options"
  spec.version = "1.5.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "rails_default_url_options"
  spec.description = "description: rails_default_url_options kicks the ass"

  spec.files =
["README.md",
 "Rakefile",
 "lib",
 "lib/rails_default_url_options.rb",
 "rails_default_url_options.gemspec"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["map", " >= 6.0.0"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/rails_default_url_options"
end
