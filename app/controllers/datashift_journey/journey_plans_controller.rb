require_dependency 'datashift_journey/application_controller'

module DatashiftJourney

  class JourneyPlansController < ApplicationController

    include ValidateState

    # Run BEFORE other filters to ensure the current journey_plan has been selected from the DB
    prepend_before_action :set_journey_plan, only: [:new, :destroy, :back_a_state]

    prepend_before_action :set_reform_object, only: [:create, :edit, :update]
    #prepend_before_action :set_journey_plan_class, only: [:create]

    # Validate state and state related params - covers certain edge cases such as browser refresh
    before_action :validate_state, only: [:edit, :update]

    def new
      # Find and create the form object, backing the current states view
      reform = FormObjectFactory.form_object_for(journey_plan)

      render locals: { journey_plan: journey_plan, form: reform }
    end

    def create
      # TOFIX - Validation from params is broken
      # NoMethodError (undefined method `each_with_index' for #<ActionController::Parameters:0x000055eacfa2c370>):
      # 16:50:36 web.1       | representable (3.0.4) lib/representable/pipeline.rb:38:in `call'
      result = true
      #result = form.validate(params)
      #logger.debug("VALIDATION FAILED - Form Errors [#{form.errors.inspect}]") unless result

      #redirect_to(form.redirection_url) && return if form.redirect?

      journey_plan = journey_plan_class.new

      form_params = params.fetch(@reform.params_key, {})

      form_params["data_nodes"] # =>{"form_field"=>{"0"=>"name", "1"=>"namespace"}, "field_value"=>{"0"=>"dfsdf", "1"=>"ghfghf"}}}

      fields = form_params["data_nodes"]["form_field"]
      values = form_params["data_nodes"]["field_value"]

      fields.each do |idx, name|
        ff = Collector::FormField.where(name: name, form_definition: @reform.definition).first
        next unless ff
        Collector::DataNode.find_or_create_by!(plan: journey_plan, form_field: ff) do |node|
          node.field_value = values[idx]
        end
      end

      #if result && form.save
      logger.debug("CREATED Plan [#{journey_plan.inspect}] - Move to Next")
      puts journey_plan.inspect
      move_next(journey_plan)
      # else
      #  render :new, locals: { journey_plan: form.journey_plan, form: form }
      # end
    end

    def back_a_state
      respond_to do |format|
        logger.debug("BACK Requested - current [#{journey_plan.state}] - previous [#{journey_plan.previous_state_name}]")

        journey_plan.back!

        if journey_plan.save

          logger.debug("Successfully back a step - state now [#{journey_plan.state}]")

          format.html do
            redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
          end

        else
          format.html { render :edit }
        end
      end
    end

    def edit
      logger.debug "Editing journey_plan [#{journey_plan.inspect}]"
      render locals: { journey_plan: @journey_plan, form: @reform }
    end

    def update
      # form = FormObjectFactory.form_object_for(journey_plan)
      #
      # logger.debug("UPDATE - CALLING VALIDATE ON Form #{form.class}")
      #
      # result = form.validate(params)
      #
      # redirect_to(form.redirection_url) && return if form.redirect?
      #
      # if result && form.save
      #   logger.debug("SUCCESS - Updated #{journey_plan.inspect}")
      #
      #   move_next(journey_plan)
      # else
      #   logger.debug("FAILED - Form Errors [#{form.errors.inspect}]")
      #
      #   render :edit, locals: { journey_plan: journey_plan, form: form }
      # end
      form_params = params.fetch(@reform.params_key, {})

      data_nodes = form_params["data_nodes"] # =>{"form_field"=>{"0"=>"name", "1"=>"namespace"}, "field_value"=>{"0"=>"dfsdf", "1"=>"ghfghf"}}}

      if data_nodes.present?
        fields = form_params["data_nodes"]["form_field"]
        values = form_params["data_nodes"]["field_value"]

        fields.each do |idx, name|
          ff = Collector::FormField.where(name: name, form_definition: @reform.definition).first
          next unless ff
          Collector::DataNode.find_or_create_by!(plan: journey_plan, form_field: ff) do |node|
            node.field_value = values[idx]
          end
        end
      end

      logger.debug("UPDATED Plan [#{journey_plan.inspect}] - Move to Next")
      puts journey_plan.inspect

      move_next(journey_plan) && return
    end # UPDATE

    private

    def move_next(journey_plan)
      journey_plan.reload

      if journey_plan.next_state_name.blank?
        logger.error("JOURNEY ENDED - no next transition - rendering 'journey_end'")
        redirect_to(datashift_journey.journey_end_path(journey_plan)) && return
      end

      # if there is no next event, state_machine dynamic helper can_next? not available
      unless journey_plan.respond_to?('can_skip_fwd?')
        logger.error("JOURNEY Cannot proceed - no next transition - rendering 'journey_end'")
        redirect_to(datashift_journey.journey_end_path(journey_plan)) && return
      end

      if journey_plan.can_skip_fwd?
        logger.error("JOURNEY Can proceed - transitioning to next event'")
        pp journey_plan.state
        journey_plan.skip_fwd!
        pp journey_plan.state
      else
        logger.error('JOURNEY Cannot Continue - not able to transition to next event')
      end

      pp journey_plan

      redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
    end

    def set_journey_plan_class
      @journey_plan_class = params[:journey_plan_class] ? params[:journey_plan_class].constantize : DatashiftJourney.journey_plan_class
    end

    def set_journey_plan
      set_journey_plan_class

      token = params[:id] || params[:journey_plan_id]

      # https://github.com/robertomiranda/has_secure_token
      # TODO: how to auto insert has_secure_token into the underlying journey plan model
      # and add in migration thats adds the token column
      # @journey_plan = DatashiftJourney.journey_plan_class.find_by_token!(token)
      @journey_plan = token ? journey_plan_class.find(token) : journey_plan_class.new
    end

    def set_reform_object
      set_journey_plan_class

      token = params[:id] || params[:journey_plan_id]

      journey_plan = token ? journey_plan_class.find(token) : journey_plan_class.new
      @reform = FormObjectFactory.form_object_for(journey_plan)

      @journey_plan = @reform.journey_plan
    end

    attr_reader :journey_plan_class, :journey_plan
  end
end
