
DatashiftJourney::Journey::MachineBuilder.extend_journey_plan_class(initial: :question1) do

  # FYI when using number watch out for Rails namign conventions....
  # question_1 would generate a bad form file question_1.rb for a class Question1
  # hence no '_' between a number ... so we use question1, under25_question1 etc

  sequence [:question1, :question2]

  # first define the sequences
  split_sequence :under25_sequence, [:under25_question1, :under25_question2]
  split_sequence :under35_sequence, [:under35_question1]
  split_sequence :under55_sequence, [:under55_question1, :under55_question2, :under55_question3]
  split_sequence :over55_sequence, [:over55_question1, :over55_question2]

  # now define the parent state and the routing criteria to each sequence

  split_on_equality( :age_question,
                     "age_answer",    # Helper method on journey_plan_class that returns age answer
                     under25_sequence: '25',
                     under35_sequence: '35',
                     under55_sequence: 'under 55',
                     over55_sequence: 'over 55'
  )

  # all sequences re-attach here to this common end
  sequence [:review, :complete ]

#after_transition to: :page_two, do: :page_two_event_hook

end

DatashiftJourney::Collector.class_eval do

  # mock up a random answer helper for split_on_equality
  def age_answer
    ['25','35','under 55','over 55'].sample
  end

end
