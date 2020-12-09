module DatashiftJourney

  module GenerateCommon

    # Copied from https://github.com/rails/rails/blob/6-0-stable/activerecord/lib/rails/generators/active_record/migration.rb#L12-L16

    # Implement the required interface for Rails::Generators::Migration.
    def next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def model_path
      @model_path ||= File.join(destination_root, "app", "models", journey_plan_filename)
    end

    # Module name  = options[:journey_class]Journey

    def journey_plan_filename
      "#{DatashiftJourney.journey_plan_class.to_s.underscore}.rb"
    end
    #
    # def concern_file(journey_class)
    #   "#{journey_class.underscore}_journey.rb"
    # end
    #
    # def decorator_file(journey_class)
    #   "#{journey_class.underscore}_decorator.rb"
    # end

  end

end
