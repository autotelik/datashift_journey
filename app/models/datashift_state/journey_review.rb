module DatashiftState
  # This handles supplying data for a SUMMARY or REVIEW page or e.g. an email contaning a summary,
  # usually as the key/value data, associated with an Enrollment state.
  #
  # N.B - Our state engine models the state of the journey (not essentially the state of the journey_plan), hence a state
  # is more analogous to Page
  # So here review data is assigned for DATA collected DURING a particular state - effectively the data
  # saved during the UPDATE on that State
  #
  class JourneyReview

    extend PrepareDataForReview
    include PrepareDataForReview

    attr_reader :journey_plan, :root_i18n_scope
    delegate :state, :state_name, to: :journey_plans

    # This class can be reused anywhere that requires yaml-parsed summary data for an journey_plan.
    # Hence the root_i18n_scope specifies the scope under which there must be a :common key at
    # least. It is recommended that the root_i18n_scopeis a folder under a config/locales
    # directory containing at least a common.en.yml file, and probably organisation-
    # specific yml files too, which override common sections (see #prepare_review_data_list).
    def initialize(journey_plan, root_i18n_scope = '.journey_plan_review')
      @journey_plan = journey_plan
      @root_i18n_scope = root_i18n_scope
    end

    # Merge common 'sections' in the review data with any app-specific
    # sections; if an app-specific section matches by heading (title) then it replaces
    # the standard one. In this way apps can override discrete sections
    # in the summary data.
    #
    def prepare_review_data_list
      merged_sections = common_sections.each_with_index do |common_section, idx|
        replacement = organisation_specific_sections.find do |org_specific_section|
          org_specific_section.heading == common_section.heading
        end
        common_sections[idx] = replacement if replacement
      end
      merged_sections
    end

    private

    def common_sections
      @common_sections ||= prepare_from_locale(journey_plan, common_i18n_key)
    end

    def app_specific_sections
      @app_specific_review_data ||= begin
        prepare_from_locale(journey_plan, app_type_i18n_key)
      end
    end

    # e.g. ".journey_plan_review"
    def common_i18n_key
      root_i18n_scope.to_s
    end

    # e.g. ".journey_plan_review.limited_company"
    def app_type_i18n_key
      "#{root_i18n_scope}.#{@journey_plan.app.type_name}"
    end
  end
end
