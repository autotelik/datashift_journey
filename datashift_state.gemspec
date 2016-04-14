# rubocop:disable Metrics/LineLength
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "datashift_state/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "datashift_state"
  s.version     = DatashiftState::VERSION
  s.authors     = ["tom statter"]
  s.email       = ["github@autotelik.co.uk"]
  s.homepage    = "http://github.com/autotelik/datashift_state"
  s.summary     = "Package containing state engine and jounrey planning"
  s.description = "Package containing state engine and jounrey planning"
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "state_machines-activerecord", "~> 0.2"
  s.add_dependency "dotenv-rails", "~> 2.1" # We use Env Vars to drive some config. This gem loads environment variables from .env into ENV.
  s.add_dependency "sass-rails", "~> 5.0"
  s.add_dependency "coffee-rails", "~> 4.1"
  s.add_dependency "high_voltage", "~> 2.4" # Rails engine for static pages. https://github.com/thoughtbot/high_voltage
  s.add_dependency "thor", "~> 0.19"
  s.add_dependency "rest-client", "~> 2.0.0.rc2"

  s.add_development_dependency "rspec-rails", "~> 3.4"
  s.add_development_dependency "factory_girl_rails", "~> 4.6"
  s.add_development_dependency "mailcatcher", "~> 0.6"  # A toy SMTP server run on port 1025 catching emails, displaying them on HTTP port 1080.
  s.add_development_dependency "pry-rails", "~> 0.3"
  s.add_development_dependency "i18n-tasks", "~> 0.9" # We use i18n-tasks to better manage our translations and ensure we don"t miss any
  s.add_development_dependency "byebug"
end
