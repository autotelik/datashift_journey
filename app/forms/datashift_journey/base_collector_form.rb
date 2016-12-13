module DatashiftJourney

  class BaseCollectorForm < DatashiftJourney::BaseForm

    alias :collector journey_plan

    def self.factory(journey)
      no_form_name = name.chomp('Form')

      form_field = DatashiftJourney::Models::FormField.new(
        form: name,
        field: no_form_name.underscore,
        field_presentation: no_form_name.titleize,
        field_type: 'string'
      )

      new(form_field, journey)
    end

    def save
      sync    # Update the model so we can neatly check/use the Form's data

      find_model = collector.nodes_for_form_and_field(model.form, model.field).first

      if find_model
        find_model.update(field_value: model.field_value)
        find_model.save
      else
        super # saves the model

        collector.form_fields << model
        collector.save
      end
    end

  end

end
