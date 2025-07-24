# frozen_string_literal: true

# First require the LCOV formatter
require "simplecov-lcov"

# Configure SimpleCov LCOV formatter
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
  c.lcov_file_name = "lcov.info"
  c.output_directory = "coverage"
end

# Print a message to confirm .simplecov is loaded
puts "Loading .simplecov configuration file..."

# Start SimpleCov with appropriate configuration
# Note: Use 'rails' preset only if this is a Rails gem, otherwise use default
SimpleCov.start do
  # Don't get coverage on the test files themselves
  add_filter "/spec/"

  # You can add additional filters here if needed
  # add_filter '/config/'

  # You can also add groups
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
