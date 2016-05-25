module DatashiftJourney

  class ReviewDataSection

    attr_accessor :heading
    attr_accessor :rows

    # :link_state - The target url for Change This. If not specified, defaults to the section page/state
    #               Supports :none to leave column empty
    #
    Struct.new('ReviewDataRow', :title, :data, :link_state, :link_title, :heading) do
      def target(journey_plan)
        return nil if link_state.to_sym == :none
        DatashiftJourney::Engine.routes.url_helpers.review_state_path(link_state, journey_plan)
      end
    end

    def initialize(heading)
      @heading = heading
      @rows = []
    end

    # Add a new row to this Section. Returns the ReviewDataRow created
    def add(title, data, link_state, link_title)
      rows << Struct::ReviewDataRow.new(title, data, link_state, link_title, heading)
      rows.last
    end

    delegate :size, :empty?, to: :rows

  end
end
