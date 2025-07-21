# frozen_string_literal: true

require "rails/generators/test_case"
# require "rails/generators/testing/behaviour"
# require "rails/generators/testing/setup_and_teardown"
# require "rails/generators/testing/assertions"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # config.include Rails::Generators::Testing::Behaviour
  # config.include Rails::Generators::Testing::SetupAndTeardown
  # config.include Rails::Generators::Testing::Assertions
end
