# frozen_string_literal: true

require_relative "gbc_trestle_modifier/version"
require "gbc/trestle/menu_helper"

module GbcTrestleResourceGenerator
  class Railtie < Rails::Railtie
    generators do
      require_relative "generators/gbc/trestle/resource_generator"
    end
  end
end
