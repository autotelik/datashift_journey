StateMachines::Machine.class_eval do
  # BACK - Create a 'back' event for each step (apart from first) in journey
  # You can exclude any other steps with the except list
  #
  def create_back_transitions(journey, except = [])
    journey.drop(1).each_with_index do |t, i|
      next if except.include?(t)
      puts "Creating Back transition from #{t} tp #{journey[i - 1]}"
      transition({ t => journey[i - 1] }.merge(on: :back))
    end
  end

  # NEXT - Create a 'next' event for each step (apart from last) in journey
  # You can exclude  any other steps with the except list
  #
  def create_next_transitions(journey, except = [])
    journey[0...-1].each_with_index do |t, i|
      next if except.include?(t)
      transition({ journey[i] => journey[i + 1] }.merge(on: :next))
    end
  end
end
