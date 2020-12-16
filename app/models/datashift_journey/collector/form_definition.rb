module DatashiftJourney
  module Collector

    # Associated with a REFORM class - stores related Form definition data in the DB,
    # such as the fields associated with this form.
    #
    # Each step or state in the plan will have an associated ReForm + FormDefinition
    #
    # Similar in intention to the Page Object Pattern, store and provide helpers for
    # rendering forms and HTML in the associated state View
    #
    class FormDefinition < ActiveRecord::Base

      self.table_name = 'dsj_form_definitions'

      has_many :form_fields, class_name: 'DatashiftJourney::Collector::FormField', dependent: :destroy, foreign_key: :form_definition_id
      accepts_nested_attributes_for :form_fields

      validates_presence_of :state
      validates_uniqueness_of :state

      def field_ids
        form_fields.collect(&:id)
      end

      private

      # N.B Validations are called BEFORE before_create or before_save
      before_validation do |record|
        record.state ||= DatashiftJourney::FormObjectFactory.state_name(self.klass)
      end

    end
  end
end
