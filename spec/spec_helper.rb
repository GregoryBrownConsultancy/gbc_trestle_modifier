# frozen_string_literal: true

# Create a debug file to verify this code is being executed
File.write("simplecov_debug.txt", "SimpleCov debug at #{Time.now}\n")

# Only start SimpleCov if COVERAGE environment variable is set to true
if ENV["COVERAGE"] == "true"
  # Write to debug file if COVERAGE is true
  File.write("simplecov_debug.txt", "COVERAGE is true at #{Time.now}\n", mode: "a")
  puts "Starting SimpleCov because COVERAGE=true..."

  # Load SimpleCov at the very top before any other code
  require "simplecov"
  require "simplecov-lcov"

  # Configure SimpleCov directly in spec_helper.rb
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
    c.lcov_file_name = "lcov.info"
    c.output_directory = "coverage"
  end

  SimpleCov.start do
    # Don't get coverage on the test files themselves
    add_filter "/spec/"

    # Add groups
    add_group "Lib", "lib"

    # Enable branch coverage
    enable_coverage :branch

    # Set minimum coverage thresholds (adjust as needed)
    minimum_coverage 90
    minimum_coverage_by_file 80

    # Use LCOV formatter for CI integration
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                         SimpleCov::Formatter::LcovFormatter
                                                       ])
  end
end

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "rspec"
require "gbc_trestle_modifier"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed
end
