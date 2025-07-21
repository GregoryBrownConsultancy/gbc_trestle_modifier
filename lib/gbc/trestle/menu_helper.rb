# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string/inflections"

module Gbc
  module Trestle
    # MenuHelper is responsible for assisting in rendering menu items based on
    # a configuration file. It utilizes the Trestle framework to build menu
    # items dynamically by reading from a YAML configuration file.
    class MenuHelper
      # Initializes a new MenuHelper object.
      #
      # @param base [Trestle::Resource] The Trestle::Resource object
      #   that the menu item is being added to.
      # @param group_key [String] The key of the group in the configuration file.
      # @param item_key [String] The key of the item in the configuration file.
      def initialize(base, group_key, item_key)
        @base = base
        @group_key = group_key
        @item_key = item_key
      end

      attr_reader :base, :group_key, :item_key # Use attr_reader as these are set in initialize

      # Build the menu item based on the provided configuration. This will essentially
      # call the Trestle::Resource#item method with the appropriate parameters.
      def render
        config = load_config
        group_data = find_group_data(config, group_key)
        item_data = find_item_data(group_data, item_key)

        call_trestle_item(group_data, item_data)
        # rescue KeyError => e
        #   raise ArgumentError, "Missing required configuration for menu item: #{e.message}"
      end

      private

      def call_trestle_item(group_data, item_data)
        @base.item(
          item_key, item_url(item_data),
          priority: calculate_priority(group_data, item_data),
          label: label_content(item_data),
          icon: format_icon(item_data),
          target: determine_target(item_data),
          badge: generate_badge(item_data),
          group: group_data.fetch("label") { group_key.to_s.humanize } # Fallback to humanized key
        )
      end

      def item_url(item_data)
        item_data.fetch("url") do
          raise ArgumentError, "Item '#{item_key}' in group '#{group_key}' is missing a 'url'."
        end
      end

      def label_content(item_data)
        label = item_data.fetch("label") { item_key.to_s.humanize }
        safe_text(label)
      end

      def load_config(root_path = Bundler.root)
        file_path = root_path.join("app", "admin", "menu.yml")
        raise Errno::ENOENT, "menu.yml not found at #{file_path}" unless File.exist?(file_path)

        YAML.load_file(file_path).tap do |config|
          raise TypeError, "menu.yml content is not a Hash" unless config.is_a?(Hash)
        end
      rescue Psych::SyntaxError => e
        raise "Error parsing menu.yml: #{e.message}"
      end

      def find_group_data(config, key)
        config.fetch(key) do
          raise ArgumentError, "Group '#{key}' not found in menu.yml. Available groups: #{config.keys.join(", ")}"
        end
      end

      def find_item_data(group_data, key)
        items = group_data.fetch("items") do
          raise ArgumentError, "Group '#{@group_key}' is missing an 'items' section."
        end
        items.fetch(key) do
          raise ArgumentError,
                "Item '#{key}' not found in group '#{@group_key}'. Available items: #{items.keys.join(", ")}"
        end
      end

      def calculate_priority(group_data, item_data)
        group_priority = group_data.fetch("priority", 0).to_i # Use fetch with default for robustness
        item_priority = item_data.fetch("priority", 1).to_i
        (group_priority * 100) + item_priority
      end

      def safe_text(label)
        label.html_safe
      end

      def determine_target(item_data)
        item_data.fetch("target", "_self")
      end

      def format_icon(item_data)
        icon_name = item_data.fetch("icon", nil) # Icon can be optional
        icon_name ? "fa #{icon_name}" : nil
      end

      def generate_badge(item_data)
        badge_data = item_data.fetch("badge", nil)
        return nil unless badge_data # Return nil if no badge data

        text = safe_text(badge_text(badge_data))
        type = badge_data.fetch("type") { raise ArgumentError, "Badge is missing 'type'." }
        { text: text, class: "badge-#{type}" }
      end

      def badge_text(badge_data)
        badge_data.fetch("text") { raise ArgumentError, "Badge is missing 'text'." }
      end
    end
  end
end
