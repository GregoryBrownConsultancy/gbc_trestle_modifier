# frozen_string_literal: true

require "generators/gbc/trestle/resource_generator"
require "rails/generators"
require "rails/generators/test_case"

RSpec.describe Gbc::Trestle::ResourceGenerator, type: :generator do
  let!(:destination_root) { File.expand_path("../tmp", __dir__) }

  before do
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(destination_root)
    described_class.start(["MyResource"], destination_root: destination_root)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "#admin file" do
    let(:admin_file) { File.join(destination_root, "app/admin/my_resource_admin.rb") }

    it "creates the admin file" do
      expect(File).to exist(admin_file)
    end

    it "correctly references the symbol" do
      expect(File.read(admin_file))
        .to match(/Trestle\.resource\(:my_resource\)/)
    end
    # TODO: IMPLEMENT CONTROLLER CHECK
  end

  describe "#form file" do
    let(:form_file) { File.join(destination_root, "app/admin/my_resource/form.rb") }

    it "creates the table file" do
      expect(File).to exist(form_file)
    end

    it "correctly references the module" do
      expect(File.read(form_file))
        .to match(/module MyResource/)
    end

    it "correctly references the Class" do
      expect(File.read(form_file))
        .to match(/class Form/)
    end
  end

  describe "#table file" do
    let(:table_file) { File.join(destination_root, "app/admin/my_resource/table.rb") }

    it "creates the table file" do
      expect(File).to exist(table_file)
    end

    it "correctly references the module" do
      expect(File.read(table_file))
        .to match(/module MyResource/)
    end

    it "correctly references the Class" do
      expect(File.read(table_file))
        .to match(/class Table/)
    end
  end

  describe "#routes file" do
    let(:routes_file) { File.join(destination_root, "app/admin/my_resource/routes.rb") }

    it "creates the table file" do
      expect(File).to exist(routes_file)
    end

    it "correctly references the module" do
      expect(File.read(routes_file))
        .to match(/module MyResource/)
    end

    it "correctly references the Class" do
      expect(File.read(routes_file))
        .to match(/class Routes/)
    end
  end

  describe "#controller file" do
    let(:controller_file) { File.join(destination_root, "app/admin/my_resource/controller.rb") }
    let(:admin_file) { File.join(destination_root, "app/admin/my_resource_admin.rb") }

    it "creates the table file" do
      expect(File).to exist(controller_file)
    end

    it "correctly references the module" do
      expect(File.read(controller_file))
        .to match(/module MyResource/)
    end

    it "correctly references the module Controller" do
      expect(File.read(controller_file))
        .to match(/module Controller/)
    end

    it "is referenced correctly in admin file" do
      expect(File.read(admin_file))
        .to match(/include MyResource::Controller/)
    end
  end
end
