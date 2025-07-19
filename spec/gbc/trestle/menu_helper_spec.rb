# frozen_string_literal: true

require "spec_helper"
require "gbc/trestle/menu_helper"

RSpec.describe Gbc::Trestle::MenuHelper do
  subject { described_class.new(base, group_key, item_key) }

  let(:base) { double("Trestle::Resource") }
  let(:group_key) { "analytics" }
  let(:item_key) { "sales_report" }

  let(:config_yaml) do
    {
      "analytics" => {
        "label" => "Analytics",
        "priority" => 2,
        "items" => {
          "sales_report" => {
            "url" => "/admin/sales",
            "label" => "Sales Report",
            "icon" => "chart-line",
            "priority" => 5,
            "target" => "_blank",
            "badge" => {
              "text" => "New",
              "type" => "success"
            }
          }
        }
      }
    }
  end

  before do
    allow(Rails).to receive_message_chain(:root, :join)
      .and_return("/fake/path/app/admin/menu.yml")

    allow(YAML).to receive(:load_file)
      .with("/fake/path/app/admin/menu.yml")
      .and_return(config_yaml)
  end

  describe "#render_menu" do
    # rubocop:disable RSpec/ExampleLength
    it "builds the menu item with correct options" do
      expect(menu_helper.base).to receive(:item).with(
        "sales_report", "/admin/sales",
        priority: 205, label: "Sales Report",
        icon: "fa chart-line", target: "_blank",
        badge: { text: "New", class: "badge-success" },
        group: "Analytics"
      )

      menu_helper.render_menu
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#item_priority" do
    it "computes the priority correctly" do
      group_obj = config_yaml[group_key]
      item_obj = group_obj["items"][item_key]

      # Access private method via `send`
      priority = menu_helper.send(:item_priority, group_obj, item_obj)
      expect(priority).to eq(205)
    end
  end

  describe "#target" do
    it "returns the target or _self" do
      item_obj = config_yaml[group_key]["items"][item_key]
      expect(subject.send(:target, item_obj)).to eq("_blank")
    end
  end

  describe "#icon" do
    it "returns the full FontAwesome class" do
      item_obj = config_yaml[group_key]["items"][item_key]
      expect(subject.send(:icon, item_obj)).to eq("fa chart-line")
    end
  end

  describe "#badge" do
    it "returns badge hash if present" do
      item_obj = config_yaml[group_key]["items"][item_key]
      expect(subject.send(:badge, item_obj)).to eq(
        { text: "New", class: "badge-success" }
      )
    end

    it "returns empty string if no badge" do
      item_obj = config_yaml[group_key]["items"][item_key].dup
      item_obj.delete("badge")
      expect(subject.send(:badge, item_obj)).to eq("")
    end
  end
end
