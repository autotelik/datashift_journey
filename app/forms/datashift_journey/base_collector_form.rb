module DatashiftJourney

  class BaseCollectorForm < DatashiftJourney::BaseForm

    alias :collector journey_plan

    def self.factory(journey)

      no_form_name = self.name.chomp("Form")

      data_node = DatashiftJourney::DataNode.new(
        form_name: self.name,
        field: no_form_name.underscore,
        field_presentation: no_form_name.titleize,
        field_type: "string"
      )

      new(data_node, journey)
    end

    def save
      super                 # saves the model
      collector.data_nodes << model
      collector.save
    end

  end

end
