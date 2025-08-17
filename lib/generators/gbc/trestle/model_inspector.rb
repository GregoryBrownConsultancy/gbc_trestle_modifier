module Gbc
  class ModelInspector
    # Checks if a given model name corresponds to a loaded class and is an ActiveRecord model.
    #
    # @param model_name [String] The name of the model (e.g., "User", "Product").
    # @return [Class, nil] The model class if found and is an ActiveRecord model, otherwise nil.
    def self.find_active_record_model(model_name)
      # Convert model name string to a constant (class)
      model_class = model_name.safe_constantize

      # Check if the class exists and inherits from ActiveRecord::Base
      if model_class.is_a?(Class) && model_class < ActiveRecord::Base
        return model_class
      else
        puts "Info: Model '#{model_name}' not found or is not an ActiveRecord model."
        return nil
      end
    rescue NameError
      # Handle cases where the constant doesn't exist at all
      puts "Info: Model '#{model_name}' class not defined."
      return nil
    end

    # Retrieves the database attributes (column names and types) for a given model.
    #
    # @param model_class [Class] The ActiveRecord model class.
    # @return [Hash<String, String>] A hash where keys are column names (String)
    #                                and values are their database types (String).
    #                                Returns an empty hash if no attributes are found or an error occurs.
    def self.get_model_database_attributes(model_class)
      unless model_class.is_a?(Class) && model_class < ActiveRecord::Base
        puts "Error: Provided argument is not a valid ActiveRecord model class."
        return {}
      end

      attributes = {}
      begin
        # `columns` method returns an array of ActiveRecord::ConnectionAdapters::Column objects
        model_class.columns.each do |column|
          attributes[column.name] = column.type.to_s # e.g., "string", "integer", "datetime"
        end
      rescue ActiveRecord::StatementInvalid => e
        puts "Error fetching attributes for #{model_class.name}: #{e.message}"
        puts "This might happen if the database table for the model does not exist yet."
        return {}
      rescue NoMethodError => e
        puts "Error: #{e.message}. Ensure the Rails environment is fully loaded and the model has a table."
        return {}
      end
      attributes
    end
  end
end