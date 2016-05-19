StateMachines::Machine.class_eval do

  def create_back( from, to, &block )

    if(block_given?)
      transition( from => to, on: :back, if: Proc.new(block))
    else
      transition( from => to, on: :back)
    end

=begin
    transition from: :a, to: :b, on: :back,
               if: ->(e) do
                 e.organisation.sti_class == WasteExemptionsShared::OrganisationType::Individual
               end
=end
  end

  def create_next( from, to )
    transition( {from => to}.merge(on: :next))
  end

  # BACK - Create a 'back' event for each step in list
  # Automatically removes first state, as nothing to go back to from that state
  # You can exclude any other steps with the except list
  #
  def create_back_transitions(journey, except = [])
    journey.drop(1).each_with_index do |t, i|
      next if except.include?(t)
      puts "Creating Back transition from #{t} to #{journey[i]}"
      create_back( t, journey[i] )    # n.b previous index is actually i not (i-1) due to the drop
    end
  end

  # NEXT - Create a 'next' event for each step (apart from last) in journey
  # You can exclude  any other steps with the except list
  #
  def create_next_transitions(journey, except = [])
    journey[0...-1].each_with_index do |t, i|
      next if except.include?(t)
      puts "Creating Next transition from #{t} to #{journey[i + 1]}"
      transition({ t => journey[i + 1] }.merge(on: :next))
    end

  end
end
