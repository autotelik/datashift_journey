# Details:: A set of File templates for creating Rails app files from data collected from the Node views
#           Includes scaffold files for key concepts :
#
#               model        - Guess model names and attributes from a node view and buildan ActiveRecord model
#               migrations   - Guess the fields required for amodel from node view, and build a migration file
#               seed data    - Guess the values for fields
#
module CopyKit
  module Templates
    module RailsApp
=begin

OLD WASTE EXEMPTIONS CODE - LEFT FOR REF AS MAYBE USEFUL FOR GENERATING MORE THAN JUST VIEWS

      def add_class
        return unless model

        rails_model = model.singularize

        classdef = <<-EOS
class #{model_class} < ActiveRecord::Base

  has_many :#{main_flow_model}s

end
        EOS

        model_subdir = File.join(output_path, "models")

        FileUtils.mkdir_p(model_subdir) unless File.directory?(model_subdir)

        model_file = File.join(model_subdir, "#{rails_model}.rb")

        puts "Creating MODEL file #{model_file}"

        File.open(model_file, "w") { |out| out << classdef }
      end

      def add_migration
        migration = <<-EOS
class Create#{model_class} < ActiveRecord::Migration
  def change
    create_table :#{model.tableize} do |t|
#{@migration_data}
      t.timestamps null: false
    end
  end
end
        EOS

        ts = Time.zone.now.strftime("%Y%m%d%H%M%S")

        migration_file = File.join(output_path, "#{ts}_create_#{model.singularize}.rb")

        puts "Creating MIGRATION file [#{migration_file}]"

        File.open(migration_file, "w") { |out| out << migration }
      end

      def add_seed
        unless @seed.empty?
          seed_file = File.join(output_path, "#{model}_seeds.rb")

          puts "Creating SEED file #{seed_file}"
          File.open(seed_file, "w") { |out| out << @seed }
        end
      end
=end
    end
  end
end
