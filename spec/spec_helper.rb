ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start do
    coverage_dir 'public/coverage'
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.mock_with :rr

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.include AdminControllerHelpers

  config.before(:suite) do
    #DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    #DatabaseCleaner.start
    #PaperTrail.controller_info = {}
    #PaperTrail.whodunnit = nil
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
