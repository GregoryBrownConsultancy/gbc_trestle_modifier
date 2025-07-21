# frozen_string_literal: true

require "yaml"
require "pathname"
require "fileutils"
require "tmpdir"

require "spec_helper"
require "gbc/trestle/menu_helper"

describe Gbc::Trestle::MenuHelper do
  let(:mock_base) { instance_double("Trestle::Resource") }

  # Create a temporary directory for test YAML files
  let(:temp_root_dir) { Pathname.new(Dir.mktmpdir) }
  let(:config_file_path) { temp_root_dir.join("app", "admin", "menu.yml") }

  before do
    # Ensure the 'app/admin' directory exists within our temp root
    FileUtils.mkdir_p(File.dirname(config_file_path))
    # Stub Bundler.root to point to our temporary directory for testing
    allow(Bundler).to receive(:root).and_return(temp_root_dir)
  end

  after do
    # Clean up the temporary directory after each example
    FileUtils.rm_rf(temp_root_dir)
  end

  # --- Context: Valid YAML Scenarios ---
  context "when menu.yml is valid and complete" do
    # Define a comprehensive YAML content for valid scenarios
    let(:valid_yaml_content) do
      <<~YAML
        dashboard_group:
          label: "Dashboard"
          priority: 1
          items:
            overview_item:
              url: "/admin/dashboard"
              label: "Overview"
              priority: 1
              icon: "tachometer-alt"
            settings_item:
              url: "/admin/settings"
              label: "<b>Settings</b> <small>Panel</small>" # HTML label
              priority: 2
              icon: "cogs"
              target: "_blank"
              badge:
                text: "New!"
                type: "info"
            advanced_item:
              url: "/admin/advanced"
              label: "Advanced Options"
              priority: 3
              # No icon, no target, no badge
        reports_group:
          label: "Reports Center"
          priority: 2
          items:
            sales_report:
              url: "/admin/sales"
              label: "Sales Report"
              priority: 1
            user_report:
              url: "/admin/users"
              label: "User Statistics"
              priority: 2
              badge:
                text: "📈" # Emoji in badge
                type: "success"
      YAML
    end

    before do
      # Write the valid YAML content to the temporary file before each test in this context
      File.write(config_file_path, valid_yaml_content)
    end

    # --- Test Cases for Valid YAML ---
    describe "#render with valid data" do
      it "calls base.item with correct parameters for a basic item" do
        menu_helper = described_class.new(mock_base, "dashboard_group", "overview_item")

        expect(mock_base).to receive(:item).with(
          "overview_item",
          "/admin/dashboard",
          priority: 101, # (group_priority * 100) + item_priority
          label: "Overview".html_safe, # Expect html_safe string
          icon: "fa tachometer-alt",
          target: "_self",
          badge: nil,
          group: "Dashboard"
        )
        menu_helper.render
      end

      it "calls base.item with correct parameters for an item with badge, target, and HTML label" do
        menu_helper = described_class.new(mock_base, "dashboard_group", "settings_item")

        expect(mock_base).to receive(:item).with(
          "settings_item",
          "/admin/settings",
          priority: 102,
          label: "<b>Settings</b> <small>Panel</small>".html_safe,
          icon: "fa cogs",
          target: "_blank",
          badge: { text: "New!".html_safe, class: "badge-info" }, # Badge text also html_safe
          group: "Dashboard"
        )
        menu_helper.render
      end

      it "handles items with missing optional fields (icon, target, badge)" do
        menu_helper = described_class.new(mock_base, "dashboard_group", "advanced_item")

        expect(mock_base).to receive(:item).with(
          "advanced_item",
          "/admin/advanced",
          priority: 103,
          label: "Advanced Options".html_safe,
          icon: nil, # Expect nil for missing icon
          target: "_self", # Expect default target
          badge: nil, # Expect nil for missing badge
          group: "Dashboard"
        )
        menu_helper.render
      end

      it "calculates priority correctly across different groups" do
        menu_helper = described_class.new(mock_base, "reports_group", "sales_report")

        expect(mock_base).to receive(:item).with(
          "sales_report",
          "/admin/sales",
          priority: 201, # (group priority 2 * 100) + item priority 1
          label: "Sales Report".html_safe,
          icon: nil,
          target: "_self",
          badge: nil,
          group: "Reports Center"
        )
        menu_helper.render
      end

      it "handles emoji in badge text" do
        menu_helper = described_class.new(mock_base, "reports_group", "user_report")

        expect(mock_base).to receive(:item).with(
          "user_report",
          "/admin/users",
          priority: 202,
          label: "User Statistics".html_safe,
          icon: nil,
          target: "_self",
          badge: { text: "📈".html_safe, class: "badge-success" },
          group: "Reports Center"
        )
        menu_helper.render
      end
    end

    # --- Test Cases for Default Behaviors (e.g., humanize) ---
    describe "#render with missing optional labels" do
      let(:yaml_without_item_label) do
        <<~YAML
          default_label_group:
            label: "Default Label Group"
            items:
              no_label_item:
                url: "/no_label"
        YAML
      end

      before do
        File.write(config_file_path, yaml_without_item_label)
      end

      it "uses humanized item_key as label if label is missing in config" do
        menu_helper = described_class.new(mock_base, "default_label_group", "no_label_item")
        expect(mock_base).to receive(:item).with(
          "no_label_item",
          "/no_label",
          hash_including(label: "No label item".html_safe) # Expect humanized key
        )
        menu_helper.render
      end
    end
  end

  # --- Context: Invalid/Incomplete YAML Scenarios (Error Handling) ---
  context "when menu.yml is invalid or incomplete" do
    describe "#render with missing data" do
      it "raises ArgumentError if the group is not found" do
        File.write(config_file_path, '{"other_group": {"items": {}}}') # Write minimal invalid content
        menu_helper = described_class.new(mock_base, "non_existent_group", "item")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Group 'non_existent_group' not found in menu.yml. Available groups: other_group/
        )
      end

      it "raises ArgumentError if the item is not found in the group" do
        File.write(config_file_path, '{"my_group": {"items": {"existing_item": {"url": "/path"}}}}')
        menu_helper = described_class.new(mock_base, "my_group", "non_existent_item")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Item 'non_existent_item' not found in group 'my_group'. Available items: existing_item/
        )
      end

      it "raises ArgumentError if 'items' key is missing in group" do
        File.write(config_file_path, '{"incomplete_group": {"label": "Incomplete"}}')
        menu_helper = described_class.new(mock_base, "incomplete_group", "some_item")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Group 'incomplete_group' is missing an 'items' section./
        )
      end

      it "raises ArgumentError if 'url' is missing for an item" do
        File.write(config_file_path, '{"group": {"items": {"item_without_url": {"label": "No URL"}}}}')
        menu_helper = described_class.new(mock_base, "group", "item_without_url")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Item 'item_without_url' in group 'group' is missing a 'url'./
        )
      end

      it "raises ArgumentError if badge 'text' is missing" do
        File.write(config_file_path,
                   '{"group": {"items": {"item_bad_badge": {"url": "/path", "badge": {"type": "danger"}}}}}')
        menu_helper = described_class.new(mock_base, "group", "item_bad_badge")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Badge is missing 'text'./
        )
      end

      it "raises ArgumentError if badge 'type' is missing" do
        File.write(config_file_path,
                   '{"group": {"items": {"item_bad_badge": {"url": "/path", "badge": {"text": "Missing type"}}}}}')
        menu_helper = described_class.new(mock_base, "group", "item_bad_badge")
        expect { menu_helper.render }.to raise_error(
          ArgumentError,
          /Badge is missing 'type'./
        )
      end
    end

    describe "#load_config (testing private method indirectly via public interface, or directly for specific errors)" do
      it "raises Errno::ENOENT if the menu.yml file is not found" do
        FileUtils.rm_f(config_file_path) # Ensure file doesn't exist
        menu_helper = described_class.new(mock_base, "any_group", "any_item")
        expect { menu_helper.render }.to raise_error(Errno::ENOENT, /menu.yml not found at/)
      end

      it "raises TypeError if the YAML content is not a hash" do
        File.write(config_file_path, "- list_item_1\n- list_item_2") # Invalid YAML for top-level hash
        menu_helper = described_class.new(mock_base, "any_group", "any_item")
        expect { menu_helper.render }.to raise_error(TypeError, /menu.yml content is not a Hash/)
      end

      it "raises a runtime error for Psych::SyntaxError (malformed YAML)" do
        File.write(config_file_path, "malformed: -") # Syntax error
        menu_helper = described_class.new(mock_base, "any_group", "any_item")
        expect { menu_helper.render }.to raise_error(RuntimeError, /Error parsing menu.yml: /)
      end
    end
  end
end
