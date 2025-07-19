# frozen_string_literal: true

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
      # @param group [String] The key of the group in the configuration file.
      # @param item [String] The key of the item in the configuration file.
      def initialize(base, group, item)
        @base = base
        @group = group
        @item = item
      end

      attr_accessor :base, :group, :item

      def render_menu
        config = load_config
        group_obj = config[group]
        item_obj = group_obj["items"][item]

        base.item(
          item, item_obj["url"],
          priority: item_priority(group_obj, item_obj),
          label: item_obj["label"], icon: icon(item_obj),
          target: target(item_obj), badge: badge(item_obj),
          group: group_obj["label"]
        )
      end

      private

      def load_config
        YAML.load_file(Rails.root.join("app", "admin", "menu.yml"))
      end

      def item_priority(group_obj, item_obj)
        ((group_obj["priority"].to_i || 0) * 100) + (item_obj["priority"].to_i || 1)
      end

      def target(item_obj)
        item_obj["target"] || "_self"
      end

      def icon(item_obj)
        "fa #{item_obj["icon"]}"
      end

      def badge(item_obj)
        return "" unless item_obj["badge"]

        { text: item_obj["badge"]["text"], class: "badge-#{item_obj["badge"]["type"]}" }
      end
    end
  end
end
