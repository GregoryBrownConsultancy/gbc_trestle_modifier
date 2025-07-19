# frozen_string_literal: true

require "rails/generators"

module Gbc
  module Trestle
    class ResourceGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string,
                      desc: "The name for the Trestle admin resource (e.g., Product, UserGroup)."

      argument :model, type: :string, required: false,
                       desc: "The associated model name (optional, e.g., Product, Item)."

      # Description displayed when running `rails generate custom:trestle --help`.
      desc "Generates a Trestle admin folder and files for a given resource."
      def start
        say_status "building", "Building new Trestle resource"
      end

      # 1. Create the dedicated folder for the Trestle admin files.
      def create_admin_folder
        # `empty_directory` ensures the directory exists and is empty if it was there before.
        empty_directory admin_folder_path
        # `say_status` provides feedback to the user in the console.
      end

      # 2. Copy the static Table.rb file.
      def create_table_template
        # `copy_file` copies a file from the source_root to the destination path.
        # No ERB processing is done here.
        template "template_table.rb.erb", "#{admin_folder_path}/table.rb"
      end

      def create_form_template
        # `copy_file` copies a file from the source_root to the destination path.
        # No ERB processing is done here.
        template "template_form.rb.erb", "#{admin_folder_path}/form.rb"
      end

      def create_routes_template
        # `copy_file` copies a file from the source_root to the destination path.
        # No ERB processing is done here.
        template "template_routes.rb.erb", "#{admin_folder_path}/routes.rb"
      end

      # 3. Process and copy the main admin template file.
      def process_admin_template
        # `template` processes an ERB file and copies the result.
        # Variables defined in this generator class (like `file_name`, `model_name_snake_cased`)
        # are accessible within the ERB template.
        template "template_admin.rb.erb", "#{admin_root_path}/#{file_name}_admin.rb"
        say_status "create", "Admin file: #{admin_root_path}/#{file_name}_admin.rb"
      end

      private

      # --- Helper Methods ---

      # Determines the snake_cased name of the resource, used for folder and file names.
      # Example: "Product" -> "product", "UserGroup" -> "user_group"
      def file_name
        name.underscore
      end

      def file_name_classified
        name.classify
      end

      def admin_root_path
        "app/admin"
      end

      # Constructs the full path for the admin resource's folder.
      # Example: "app/admin/product"
      def admin_folder_path
        "#{admin_root_path}/#{file_name}"
      end

      # Returns the snake_cased version of the provided model name, if present.
      # Example: "Order" -> "order", nil -> nil
      def model_name_snake_cased
        model.present? ? model.underscore : nil
      end

      # Returns the classified (camel-cased) version of the provided model name, if present.
      # Used for the `model` option in Trestle.resource.
      # Example: "order" -> "Order", nil -> nil
      def model_name_classified
        model.present? ? model.classify : nil
      end

      def model_definition
        model.present? ? ", model: #{model_name_classified}" : ""
      end
    end
  end
end
