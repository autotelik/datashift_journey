require_relative '../generate_common'

module DatashiftJourney
  class CollectorGenerator < Rails::Generators::Base

    source_root File.expand_path('templates', __dir__)

    include Rails::Generators::Migration

    include DatashiftJourney::GenerateCommon
    extend DatashiftJourney::GenerateCommon

    desc 'Copies over migrations enabling use of our generic data collection facilities'

    def create_collector
      @migration_version = '6.1'   # TODO: how can we get this dynamically from Rails version ?

      migration_template 'collector_migration.rb', 'db/migrate/datashift_journey_create_collector.rb'#, migration_version: migration_version

      inject_into_file model_path, :after => /class.* < ApplicationRecord/ do
        "\ninclude DatashiftJourney::Collector::PlanConcern"
      end

      route(%(
          # This mounts Datashift Journey's Collector routes
          #
          scope :api, constraints: { format: 'json' } do
            scope :v1 do
              resources :page_states, only: [:create], controller: 'datashift_journey/page_states'
            end
          end
        )
      )
    end

  end
end
