# frozen_string_literal: true

require_relative "gbc_trestle_modifier/version"
require "gbc/trestle/menu_helper"

module GbcTrestleResourceGenerator
  # A Railtie for GbcTrestleResourceGenerator.
  #
  # GbcTrestleResourceGenerator is a gem that provides a custom generator for
  # Trestle resources. The generator is used to create a complete resource
  # folder structure for Trestle, instead of a single file. In this structure,
  # the resource file is split into a controller, a table, a form and a routes.
  #
  # @author bugzbrown
  class Railtie < Rails::Railtie
    generators do
      require_relative "generators/gbc/trestle/resource_generator"
    end
  end
end
