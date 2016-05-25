ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'shoulda-matchers'
require "shoulda/matchers"

Rails.backtrace_cleaner.remove_silencers!

# Load our Engine
require File.expand_path("../../lib/datashift_journey",  __FILE__)

RSpec.configure do |config|

  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  config.include FactoryGirl::Syntax::Methods

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
