module DatashiftState

  module PrepareDataForReview

    extend ActiveSupport::Concern

    def self.included base
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      # You can build your review page within a YAML config file (locale file)
      # It supports a simple DSL in below format.
      #
      # SYNTAX :
      #     Indentation, usually 2 spaces, or a 2 space TAB, is very important
      #     <> are used to illustrate the elements that accept free text
      #
      # ROW :
      #
      # Each ReviewDataRow has upto 3 elements
      #
      #   :title:      The string for Column 1, the row header
      #
      #   :method: The actual database data for Column2, method to call on the model, or the association object
      #
      #   :link_state: The state the change me links, jumps back to.
      #                Optional, if unspecified,  uses the section block (state)
      #
      # FULL DSL :
      #
      # <key>:
      #   sections:
      #     <section_block - usually a state>:          # The Link target defaults to this, if no explicit state set
      #       section_heading: "Farming data"           # The section title - that spans the 3 columns
      #       direct:                                   # Non association data i.e directly on the parent model
      #         -  :title: "Activity is on a farm"      # Column title. The - indicates a list, each mini block is a row
      #            :method: on_a_farm                   # Method called on association to get real (DB) data to display
      #         -  :title: "Registrant is a farmer"     # Next mini block - Each section can have multiple rows
      #            :method: is_a_farmer
      #     <next section_block - choosing_site_address>:
      #       section_heading: Waste Activity Location
      #       associations:
      #         <association>                     # As well as direct, supports Rails associations, on supplied model
      #           -  :title: "1st Column"
      #              :method: full_name           # Ruby method called on association, returns real (DB) data to display
      #              :link_state: state           # The link target - i.e state to JUMP to, in order to EDIT the data
      #          site_address:                    # Again, section can contain multiple rows, from multiple associations
      #            -  :title: "Address"
      #               :method:                    # No method supplied, data will be WHOLE associated object
      #
      # EXAMPLE:
      #
      # journey_plan_review:
      #   sections:
      #     choosing_farming_data:
      #       section_heading: "Farming data"
      #       direct:
      #         -  :title: "Activity is on a farm"
      #            :method: on_a_farm
      #         -  :title: "Registrant is a farmer"
      #            :method: is_a_farmer
      #     choosing_site_address:
      #       section_heading: Waste Activity Location
      #       associations:
      #          site_address:
      #            -  :title: "Address"
      #               :method:                    # No state cos Partial can render WHOLE Address object
      #            -  :title: "Grid reference"
      #               :method: grid_reference
      #     choosing_exemption:
      #       section_heading: Waste Exemption Codes
      #       associations:
      #         exemption:
      #           -  :title: "Waste Exemptions"
      #              :method: code
      #
      # NOTES
      #
      # Method can be left blank, in this case the data is the association object, so this must be display-able
      #
      # For example, this will cause @journey_plan.site_address to be sent to the review partial, which we know has
      # special use case for Address, which renders a display address partial
      #
      #          site_address:
      #            -  :title: "Address"
      #               :method:
      #
      attr_reader :review_data

      def prepare_from_locale(model, locale_key = ".journey_plan_review")
        sections = I18n.t("#{locale_key}.sections", default: {})

        Rails.logger.debug("Review Sections: #{sections.inspect}")

        unless(sections.is_a?(Hash))
          Rails.logger.error("Bad syntax in your review YAML - Expect a 'sections' Hash element")
          raise RuntimeError.new("Bad syntax in your review YAML - Expect a 'sections' Hash element")
        end

        @model_object = model

        # Return a collection of Sections (ReviewData), each section has multiple rows

        sections.collect do |section, data|
          next unless(data[:section_heading])

          @current_section = section

          @review_data = ReviewDataSection.new(data[:section_heading])

          # Possible Enhancement required :
          # As it stands this will NOT preserve the Order as defined exactly in the YAML as it's a HASH
          # with keys - for direct & association sections - which are unordered.
          # So currently had to make arbitrary decision to process direct first, then associations

          # Direct data on parent Model, where key is - direct:
          key = "#{locale_key}.sections.#{section}.direct"

          if(I18n.exists?(key))
            I18n.t(key).each { |column| row_to_review_data(model_object, column) }
          end

          # Associated data - children of parent

          key = "#{locale_key}.sections.#{current_section}.associations"

          if(I18n.exists?(key))

            association_list = I18n.t("#{locale_key}.sections.#{current_section}.associations", default: [])

            association_list.each do |association_data|
              unless(association_data.size == 2)
                Rails.logger.error("Bad syntax in your review YAML - expect each association to have name and fields")
                next
              end

              # Each association should have a row defined as a list i.e Array
              #  -  :title: Business trading name
              #     :name: full_name
              #
              unless(association_data[1].respond_to?(:each))
                Rails.logger.error("Bad syntax in review YAML - each row needs a title, method and optional link")
                next
              end

              # The first element is the association name or chain,
              # i.e method(s) to call on the parent model to reach child with the actual data
              association_method = association_data[0].to_s

              review_object = begin
                find_association(association_method)
              rescue => e
                Rails.logger.error(e.message)
                Rails.logger.error("Bad syntax in review YAML - Could not load associated object #{association_method}")
                next
              end

              unless(review_object)
                Rails.logger.error("Nil association for #{association_method} on #{model} - no review data available")
                next
              end

              # The second element is a list of rows, made up of title, method to call on association and the state link
              association_data[1].each { |column| row_to_review_data(review_object, column) }
            end
          end

          review_data
        end
      end

      private

      attr_accessor :current_section, :current_review_object, :review_data

      attr_accessor :model_object

      def row_to_review_data(review_object, row)
        # The section name, can be used as the state, for linking whole section, rather than at field level
        link_state = row[:link_state] || current_section
        link_title = row[:link_title]

        @current_review_object = review_object

        # The review partial can support whole objects, or low level data from method call defined in the DSL
        if(row[:method].blank?)
          review_data.add(row[:title], review_object, link_state.to_s, link_title)
        else
          # rubocop:disable Style/IfInsideElse
          if(review_object.respond_to?(:each))
            review_object.each do |o|
              @current_review_object = o
              review_data.add(row[:title], send_chain(row[:method]), link_state.to_s, link_title)
            end
          else
            review_data.add(row[:title], send_chain(row[:method]), link_state.to_s, link_title)
          end

        end
      end

      def find_association(method_chain)
        arr = method_chain.to_s.split(".")

        arr.inject(model_object) {|o, a| o.send(a) }
      end

      def send_chain(method_chain)
        arr = method_chain.to_s.split(".")
        begin
          arr.inject(current_review_object) {|o, a| o.send(a) }
        rescue => e
          Rails.logger.error("Failed to process method chain #{method_chain} : #{e.message}")
          return I18n.t(".journey_plan_review.missing_data")
        end
      end

    end
  end

end
