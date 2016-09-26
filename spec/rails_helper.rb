# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods

  ActiveRecord::Migration.maintain_test_schema!

  # Use seed data in some places rather than Factories so don't clean
  # certain 'static' tables
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before do |example|
    md = example.metadata
    DatabaseCleaner.strategy = :transaction

    Capybara.current_driver =
      if md[:driver].present?
        md[:driver]
      elsif md[:js] || md[:javascript]
        :poltergeist
      else
        :rack_test
      end

    unless Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :truncation, DB_CLEANER_TRUNCATION_OPTS
    end

    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Enables shortcut, t() instead of I18n.t() in tests
  config.include AbstractController::Translation
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
