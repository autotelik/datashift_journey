module DatashiftState
  class FormObjectFactory

    class << self
      def form_object_for(journey_plan)
        klass = form_class_for(journey_plan)

        klass = null_form_for_step(journey_plan) unless klass

        raise(FormObjectError, "No form class found for state #{form_name(journey_plan.state)}") unless klass

        klass.factory(journey_plan)
      end

      def form_name(state)
        @form_name_mod ||= Configuration.call.forms_module_name

        "#{@form_name_mod}::#{state.to_s.classify}Form"
      end

      private

      def null_form_for_step(journey_plan)
        @null_form_list ||= Configuration.call.null_form_list.map! &:to_sym

        if(@null_form_list.include?(journey_plan.state.to_sym))
          DatashiftState:: NullForm
        else
          nil
        end
      end

      def form_class_for(journey_plan)
        f = form_name(journey_plan.state)

        begin
          f.constantize
        rescue => x
          Rails.logger.debug(x.backtrace.first)
          Rails.logger.debug(x.inspect)
          Rails.logger.debug("Error loading Form class #{f} - #{x.message}")
          nil
        end
      end
    end

  end
end
