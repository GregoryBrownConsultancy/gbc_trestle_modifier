# frozen_string_literal: true

# lib/gbc_trestle_modifier/railtie.rb
require "rails/railtie"

module GbcTrestleResourceGenerator
  class Railtie < Rails::Railtie
    generators do
      require_relative "../generators/gbc/gbc_trestle_modifier"
    end
  end
end
