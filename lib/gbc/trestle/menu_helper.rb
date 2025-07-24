module Gbc
  module Trestle
    class MenuHelper
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
        YAML.load_file(File.expand_path("app/admin/menu.yml", __dir__))
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
