$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_record/embedded/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_record-embedded"
  s.version     = ActiveRecord::Embedded::VERSION
  s.authors     = ["Tom Scott"]
  s.email       = ["tscott@weblinc.com"]
  s.homepage    = 'https://psychedeli.ca'
  s.summary     = 'Embedded data in your ActiveRecord models'
  s.description = s.summary
  s.license     = "MIT"

  s.files    = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features)/})
  end

  s.add_dependency "activerecord", ActiveRecord::Embedded::RAILS_VERSION

  s.add_development_dependency "rails", ActiveRecord::Embedded::RAILS_VERSION
  s.add_development_dependency "pg"
  s.add_development_dependency "pry-byebug", '~> 3'
  s.add_development_dependency "simplecov"
end
