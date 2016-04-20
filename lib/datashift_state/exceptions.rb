module DatashiftState

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

      DatashiftState.const_set(name, new_class)
    end

  end

end
