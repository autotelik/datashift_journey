# rubocop:disable Metrics/LineLength
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "datashift_journey/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "datashift_journey"
  s.version     = DatashiftJourney::VERSION
  s.authors     = ["tom statter"]
  s.email       = ["github@autotelik.co.uk"]
  s.homepage    = "http://github.com/autotelik/datashift_journey"
  s.summary     = "Package containing state engine and journey planning"
  s.description = "Package containing state engine, form based journey planning and execution"
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "state_machines-activerecord", "~> 0.2"
  s.add_dependency "reform", "~> 2.1"
  s.add_dependency "reform-rails", "~> 0.1"
  s.add_dependency "sass-rails", "~> 5.0"
  s.add_dependency "coffee-rails", "~> 4.1"
  s.add_dependency "high_voltage", "~> 3" # Rails engine for static pages. https://github.com/thoughtbot/high_voltage
  s.add_dependency "thor", "~> 0.19"
  s.add_dependency "rest-client", "~> 2.0.0.rc2"
  s.add_dependency "has_secure_token", "~> 1.0"

  s.add_development_dependency "rspec-rails", "~> 3.4"
  s.add_development_dependency "factory_girl_rails", "~> 4.6"
  s.add_development_dependency "pry-rails", "~> 0.3"

end
