module DatashiftState
  class Coordinates
    attr_accessor :easting, :northing
    alias_attribute :x, :easting
    alias_attribute :y, :northing

    def initialize(easting:, northing:)
      @easting = easting
      @northing = northing
    end

    def valid?
      easting && northing
    end
  end
end
