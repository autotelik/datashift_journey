
DatashiftJourney::Journey::MachineBuilder.extend_journey_plan_class(initial: :page_one) do

  sequence [:page_one, :page_two]

  #after_transition to: :page_two, do: :page_two_event_hook

end
