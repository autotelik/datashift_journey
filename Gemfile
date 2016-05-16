source "https://rubygems.org"
ruby "2.3.1"

gemspec

# Use the test group rather than putting gems for testing in the gemspec with
# add_development_dependency
group :test do
  gem "sqlite3", "~> 1.3"
  gem "vcr", "~> 3.0"
  gem "webmock", "~> 1.24"
  gem "shoulda-matchers", "~> 3.1", require: false
  gem "test_after_commit", "~> 1.0" # Make after_commit callbacks fire in tests
  gem "ffaker", "~> 2.2"
  gem "database_cleaner", "~> 1.5"
  gem "fuubar", "~> 2.0"            # Enhanced rspec progress formatter
  gem "capybara", "~> 2.6"
  gem "capybara-email", "~> 2.5"
end
