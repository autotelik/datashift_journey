module DatashiftJourney

  class CoreException < StandardError

    def initialize(msg)
      super
      Rails.logger.error(msg)
    end

    def self.generate(name)
      new_class = Class.new(CoreException) do
        def initialize(msg)
          super(msg)
        end
      end

      DatashiftJourney.const_set(name, new_class)
    end

  end

  class FormObjectError < CoreException; end
  class PlannerApiError < CoreException; end

end

