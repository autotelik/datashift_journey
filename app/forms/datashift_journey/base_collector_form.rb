module DatashiftJourney

  class BaseCollectorForm < DatashiftJourney::BaseForm

    def self.factory(journey_plan)
      no_form_name = name.chomp('Form')

      form = Models::Form.where(form_name: no_form_name).first_or_create

      form_field = Models::FormField.where(
          form: form,
          field: no_form_name.underscore,
          field_type: :string
      ).first_or_create

      data_node = journey_plan.data_nodes.build(form_field: form_field)

      new(data_node, journey_plan)
    end

    alias_attribute :collector, :journey_plan

  end

end
