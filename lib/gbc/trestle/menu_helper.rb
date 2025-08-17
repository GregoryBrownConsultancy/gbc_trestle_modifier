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
          label: safe(item_obj["label"]), icon: icon(item_obj),
          target: target(item_obj), badge: badge(item_obj),
          group: safe(group_obj["label"])
        )
      end

      private

      def safe(text)
        text.to_s.html_safe
      end
      def load_config
        app_root = find_app_root
        YAML.load_file(File.join(app_root, "app", "admin", "menu.yml"))
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

      def find_app_root
        # Option 1: Using Bundler.root (most common and reliable for Rails apps)
        if defined?(Bundler) && Bundler.root
          return Bundler.root.to_s
        end

        # Option 2: Fallback heuristic (less reliable, but can be used if Bundler.root isn't available)
        # This attempts to find a common Rails file (like config/application.rb)
        # by traversing up the directory tree from the current working directory.
        current_dir = Dir.pwd
        while current_dir != '/' && current_dir != File.dirname(current_dir)
          if File.exist?(File.join(current_dir, 'config', 'application.rb')) ||
            File.exist?(File.join(current_dir, 'Gemfile'))
            return current_dir
          end
          current_dir = File.dirname(current_dir)
        end

        nil # Application root not found
      end
    end
  end
end
