ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "simplecov"

SimpleCov.start do
  add_filter "spec/factories"
  add_filter "spec/dummy"
  add_filter "app"
end

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

  def parse(response)
    JSON.parse(response.body)
  end

  def parse_attribs(response)
    JSON.parse(response.body)['data']['attributes']
  end

  def dump_json(response)
    puts response.body
  end

end

# Decorate model with helper methods required for BRANCHING in Test journey plans

DatashiftJourney::Collector::Collector.class_eval do
  def construction_demolition_value
    'yes'
  end

  def registration_type_value
    # carrier_dealer_sequence:
    'carrier_dealer'
    # broker_dealer_sequence: 'broker_dealer',
    # carrier_broker_dealer_sequence: 'carrier_broker_dealer')
  end
end
