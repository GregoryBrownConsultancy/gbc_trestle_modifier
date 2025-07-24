# frozen_string_literal: true
require 'yaml'
require 'gbc/trestle/menu_helper'

RSpec.describe Gbc::Trestle::MenuHelper do
  let(:base) { double('Trestle::Navigation::Builder') }
  let(:group) { 'admin' }
  let(:item) { 'dashboard' }
  let(:config) do
    {
      'admin' => {
        'label' => 'Admin',
        'priority' => 1,
        'items' => {
          'dashboard' => {
            'label' => 'Dashboard',
            'url' => '/admin/dashboard',
            'icon' => 'fa-dashboard',
            'priority' => 1
          }
        }
      }
    }
  end

  before do
    allow(YAML).to receive(:load_file).and_return(config)
    allow(File).to receive(:exist?).and_return(true)
  end

  subject { described_class.new(base, group, item) }

  describe '#render_menu' do
    it 'calls item on base with correct parameters' do
      expect(base).to receive(:item).with(
        'dashboard',
        '/admin/dashboard',
        priority: 101,
        label: 'Dashboard',
        icon: 'fa fa-dashboard',
        target: '_self',
        badge: "",
        group: 'Admin'
      )

      subject.render_menu
    end
  end

  describe '#item_priority' do
    it 'calculates priority correctly' do
      group_obj = { 'priority' => 2 }
      item_obj = { 'priority' => 3 }
      expect(subject.send(:item_priority, group_obj, item_obj)).to eq(203)
    end
  end

  describe '#target' do
    it 'returns _self when target is not specified' do
      item_obj = {}
      expect(subject.send(:target, item_obj)).to eq('_self')
    end

    it 'returns the specified target' do
      item_obj = { 'target' => '_blank' }
      expect(subject.send(:target, item_obj)).to eq('_blank')
    end
  end

  describe '#icon' do
    it 'returns the icon with fa prefix' do
      item_obj = { 'icon' => 'dashboard' }
      expect(subject.send(:icon, item_obj)).to eq('fa dashboard')
    end
  end

  describe '#badge' do
    it 'returns empty string when no badge is present' do
      item_obj = { 'badge' => nil }
      expect(subject.send(:badge, item_obj)).to eq('')
    end

    it 'returns badge hash when badge is present' do
      item_obj = { 'badge' => { 'text' => 'New', 'type' => 'success' } }
      expect(subject.send(:badge, item_obj)).to eq(
        { text: 'New', class: 'badge-success' }
      )
    end
  end
end
