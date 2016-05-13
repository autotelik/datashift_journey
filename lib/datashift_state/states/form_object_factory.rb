module DatashiftState
  module States
    class FormObjectFactory
      class << self

        def form_object_for(journey_plan)
          klass = setup_form_object(journey_plan.state)

          raise(FormObjectError, "No form object found for #{form_name(journey_plan.state)}") unless klass

          klass.factory(journey_plan)
        end

        private

        def form_name(state)
          @form_name_mod ||= "DatashiftState::#{Configuration.call.state_module_name}"

          "#{@form_name_mod}::#{state.to_s.classify}Form"
        end

        def setup_form_object(state)
          f = form_name(state)

          begin
            f.constantize
          rescue NameError
            Rails.logger.debug("Error loading Form class #{f} ")
            nil
          end
        end

      end
    end
  end
end
