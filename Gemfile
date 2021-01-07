source "https://rubygems.org"
ruby "2.7.1"

gemspec

group :development, :test do
  gem 'dotenv-rails'

  # These can be used in DEV for creating an enrollment at any stage in life cycle
  # N.B not in gemspec and require is false so factories aren't loaded during e.g db:migrate
  gem 'factory_bot_rails', require: false
  gem 'ffaker'
  gem 'byebug'
  gem 'rswag'
end

# Use the test group rather than putting gems for testing in the gemspec with
# add_development_dependency
group :test do
  gem "pg"
  gem "database_cleaner"
  gem "capybara"
  gem "simplecov"
end
