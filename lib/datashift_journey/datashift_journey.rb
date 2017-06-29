

module DatashiftJourney

  def self.library_path
    File.expand_path("#{File.dirname(__FILE__)}/../lib")
  end

  # Load all the datashift Thor commands and make them available throughout app

  def self.load_commands
    base = File.join(library_path, 'tasks', '**')

    Dir["#{base}/*.thor"].each do |f|
      next unless File.file?(f)
      load(f)
    end
  end

  def self.journey_plan_class=(x)
    raise 'DSJ - journey_plan_class MUST be String or Symbol, not a Class.' if x.is_a?(Class)

    @journey_plan_class = x

    @journey_plan_class = x.to_s.constantize if x.is_a?(String) || x.is_a?(Symbol)
  end

  def self.journey_plan_class
    @journey_plan_class ||= init_journey_plan_class
  end

  def self.use_default_journey_plan_class
    DatashiftJourney.journey_plan_class = DatashiftJourney.default_journey_plan_class_name
  end

  def self.default_journey_plan_class_name
    collector_journey_plan_class.name
  end

  def self.collector_journey_plan_class
    DatashiftJourney::Collector::Collector
  end

  def self.using_collector?
    DatashiftJourney.journey_plan_class == collector_journey_plan_class
  end

  class << self
    private

    def init_journey_plan_class
      @journey_plan_class = (default_journey_plan_class_name).constantize unless @journey_plan_class

      @journey_plan_class
    end
  end

end
