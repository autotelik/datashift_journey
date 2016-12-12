source "https://rubygems.org"
ruby "2.3.2"

gemspec

group :development, :test do
  # These can be used in DEV for creating an enrollment at any stage in life cycle
  # N.B not in gemspec and require is false so factories aren't loaded during e.g db:migrate
  gem 'factory_girl', require: false
  gem 'factory_girl_rails', require: false
  gem 'ffaker'
  gem 'byebug'
end

# Use the test group rather than putting gems for testing in the gemspec with
# add_development_dependency
group :test do
  gem "sqlite3", "~> 1.3"
  gem "shoulda-matchers", "~> 3.1", require: false
  gem "database_cleaner", "~> 1.5"
  gem "fuubar", "~> 2.0"            # Enhanced rspec progress formatter
  gem "capybara", "~> 2.6"
end
