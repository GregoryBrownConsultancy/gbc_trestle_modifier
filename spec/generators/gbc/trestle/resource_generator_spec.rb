# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "generator_spec"
require "generators/gbc/trestle/resource_generator"
require "fileutils"
require "pathname"
require "stringio"

# Mock Rails module if it doesn't exist in the test environment
unless defined?(Rails)
  module Rails
    def self.root
      Pathname.new(Dir.pwd)
    end
  end
end

RSpec.describe Gbc::Trestle::ResourceGenerator do
  include GeneratorSpec::TestCase

  # Use GeneratorSpec's built-in destination management
  destination File.expand_path("../../../../tmp", __dir__)

  before do
    FileUtils.mkdir_p(destination_root)
    FileUtils.rm_rf(Dir["#{destination_root}/*"]) # clean up any previous contents
    prepare_destination

    # Mock Rails.root to the test destination
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root))
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  # Helper methods for testing
  def file_exists?(path)
    File.exist?(File.join(destination_root, path))
  end

  def file_content(path)
    File.read(File.join(destination_root, path))
  end

  # Run generator with given arguments
  def run_generator(args = [])
    FileUtils.mkdir_p(destination_root)
    FileUtils.rm_rf(Dir["#{destination_root}/*"]) # clean up any previous contents
    generator = described_class.new(args)
    generator.destination_root = destination_root
    generator.invoke_all
  end

  context "when only name argument is provided" do
    it "creates all the expected files" do
      run_generator(["Product"])

      expect(file_exists?("app/admin/product/table.rb")).to be true
      expect(file_exists?("app/admin/product/form.rb")).to be true
      expect(file_exists?("app/admin/product/routes.rb")).to be true
      expect(file_exists?("app/admin/product/collection.rb")).to be true
      expect(file_exists?("app/admin/product/scopes.rb")).to be true
      expect(file_exists?("app/admin/product/search.rb")).to be true
      expect(file_exists?("app/admin/product_admin.rb")).to be true
    end

    it "generates the admin file with correct content" do
      run_generator(["Product"])
      admin_file = File.join(destination_root, "app/admin/product_admin.rb")

      expect(File.exist?(admin_file)).to be true
      content = File.read(admin_file)
      expect(content).to include("Trestle.resource(:product)")
      expect(content).not_to include(", model:")
    end
  end

  context "when both name and model arguments are provided" do
    it "creates all the expected files" do
      run_generator(%w[ProductAdmin Product])

      expect(file_exists?("app/admin/product_admin/table.rb")).to be true
      expect(file_exists?("app/admin/product_admin/form.rb")).to be true
      expect(file_exists?("app/admin/product_admin/routes.rb")).to be true
      expect(file_exists?("app/admin/product_admin/collection.rb")).to be true
      expect(file_exists?("app/admin/product_admin/scopes.rb")).to be true
      expect(file_exists?("app/admin/product_admin/search.rb")).to be true
      expect(file_exists?("app/admin/product_admin_admin.rb")).to be true
    end

    it "generates the admin file with correct model reference" do
      run_generator(%w[ProductAdmin Product])
      admin_file = File.join(destination_root, "app/admin/product_admin_admin.rb")

      expect(File.exist?(admin_file)).to be true
      content = File.read(admin_file)
      expect(content).to include("Trestle.resource(:product_admin")
      expect(content).to include(", model: Product")
    end
  end

  describe "helper methods" do
    let(:generator) { described_class.new(%w[UserGroup User]) }
    let(:no_model) { described_class.new(%w[OtherGroup]) }

    it { expect(generator.send(:file_name)).to eq("user_group") }
    it { expect(generator.send(:file_name_classified)).to eq("UserGroup") }
    it { expect(generator.send(:admin_root_path)).to eq("app/admin") }
    it { expect(generator.send(:admin_folder_path)).to eq("app/admin/user_group") }
    it { expect(generator.send(:model_name_snake_cased)).to eq("user") }
    it { expect(generator.send(:model_name_classified)).to eq("User") }
    it { expect(generator.send(:model_definition)).to eq(", model: User") }

    it { expect(no_model.send(:model_name_snake_cased)).to be_nil }
    it { expect(no_model.send(:model_name_classified)).to be_nil }
  end

  describe "template generation" do
    before do
      run_generator(["Product"])
    end

    it "generates all template files" do
      %w[table.rb form.rb routes.rb collection.rb scopes.rb search.rb].each do |file|
        expect(file_exists?("app/admin/product/#{file}")).to be true
      end
    end

    it "generates the main admin file" do
      expect(file_exists?("app/admin/product_admin.rb")).to be true
    end

    describe "template content" do
      before { run_generator(%w[Product Item]) }

      after do
        puts "Cleanup test destination directory: #{destination_root}"
        FileUtils.rm_rf(destination_root)
      end

      it "correctly processes the admin template with ERB" do
        content = file_content("app/admin/product_admin.rb")
        expect(content).to include("Trestle.resource(:product")
        expect(content).to include(", model: Item")
        expect(content).not_to include("<%")
      end

      it "correctly processes supporting templates" do
        %w[table.rb form.rb].each do |file|
          content = file_content("app/admin/product/#{file}")
          expect(content).not_to include("<%")
        end
      end
    end

    describe "edge cases" do
      it "handles names with special characters" do
        run_generator(["User_Profile"])
        expect(file_exists?("app/admin/user_profile/table.rb")).to be true
        expect(file_exists?("app/admin/user_profile_admin.rb")).to be true

        run_generator(["UserProfile"])
        expect(file_exists?("app/admin/user_profile/table.rb")).to be true
        expect(file_exists?("app/admin/user_profile_admin.rb")).to be true
      end
    end
  end

  # describe "generator methods" do
  #   it "calls the expected methods in sequence" do
  #     generator = described_class.new(["Product"])
  #     generator.destination_root = destination_root

  #     allow(generator).to receive(:template)
  #     allow(generator).to receive(:empty_directory)

  #     expect(generator).to receive(:start).ordered
  #     expect(generator).to receive(:info1).ordered
  #     expect(generator).to receive(:create_admin_folder).ordered
  #     expect(generator).to receive(:create_table_template).ordered
  #     expect(generator).to receive(:create_form_template).ordered
  #     expect(generator).to receive(:create_routes_template).ordered
  #     expect(generator).to receive(:create_collection_template).ordered
  #     expect(generator).to receive(:create_scopes_template).ordered
  #     expect(generator).to receive(:create_search_template).ordered
  #     expect(generator).to receive(:info2).ordered
  #     expect(generator).to receive(:process_admin_template).ordered

  #     generator.invoke_all
  #   end
  # end

  describe "error handling" do
    it "handles missing arguments gracefully" do
      expect { described_class.new([]) }.to raise_error(Thor::RequiredArgumentMissingError)
    end
  end
end
