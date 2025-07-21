# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in gbc_trestle_modifier.gemspec
gemspec

group :development, :test do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.12"

  # Code quality tools
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false

  # Needed for Rails::Generators::TestCase
  gem "rails", require: false
  gem "railties", require: false
end
