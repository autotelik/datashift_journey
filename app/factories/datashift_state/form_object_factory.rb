module DatashiftState
  class FormObjectFactory

    class << self
      def form_object_for(journey_plan)
        klass = setup_form_object(journey_plan)

        raise(FormObjectError, "No form object defined for State #{journey_plan.state}") unless klass

        klass.factory(journey_plan)
      end

      private

      def setup_form_object(journey_plan)
        mod = Configuration.call.forms_module_name

        form_name = "#{mod}::#{journey_plan.state.to_s.classify}Form"

        begin
          form_name.constantize
        rescue NameError => x
          Rails.logger.debug(x.backtrace.first)
          Rails.logger.debug(x.inspect)
          Rails.logger.debug("Error loading Form class #{form_name} ")
          nil
        end
      end
    end

  end
end
