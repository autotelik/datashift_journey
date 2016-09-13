
DatashiftJourney::Journey::MachineBuilder.extend_journey_plan_class(initial: :page_one) do

  sequence [:question_1, :question_2]

  # first define the sequences
  split_sequence :under_25_sequence, [:under_25_question_1, :under_25_question_2]
  split_sequence :under_35_sequence, [:under_35_question_1]
  split_sequence :under_55_sequence, [:under_55_question_1, :under_55_question_2, :under_55_question_3]
  split_sequence :over_55_sequence, [:over_55_question_1, :over_55_question_2]

  # now define the parent state and the routing criteria to each sequence

  split_on_equality( :age_question,
                     "payment_card",    # Helper method on journey_plan_class that returns age answer
                     under_25_sequence: '25',
                     under_35_sequence: '35',
                     under_55_sequence: 'under 55',
                     over_55_sequence: 'over 55'
  )

  # all sequences re-attach here to this common end
  sequence [:review, :complete ]

#after_transition to: :page_two, do: :page_two_event_hook

end
