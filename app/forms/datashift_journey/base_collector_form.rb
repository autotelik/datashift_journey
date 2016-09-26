module DatashiftJourney

  class BaseCollectorForm < DatashiftJourney::BaseForm

    alias :collector journey_plan

    def self.factory(journey)
      no_form_name = name.chomp('Form')

      data_node = DatashiftJourney::DataNode.new(
        form_name: name,
        field: no_form_name.underscore,
        field_presentation: no_form_name.titleize,
        field_type: 'string'
      )

      new(data_node, journey)
    end

    def save
      sync    # Update the model so we can neatly check/use the Form's data

      find_model = collector.nodes_for_form_and_field(model.form_name, model.field).first

      if find_model
        find_model.update(field_value: model.field_value)
        find_model.save
      else
        super # saves the model

        collector.data_nodes << model
        collector.save
      end
    end

  end

end
