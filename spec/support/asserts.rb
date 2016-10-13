RSpec.configure do |_config|
  # Set of standard checks
  #
  #   Is our current state == expected_state
  #
  def expect_state_matches(journey, expected_state, message = nil)
    expect(journey.state_name).to eq(expected_state), message
    expect(journey.state).to eq(expected_state.to_s), message
    expect(journey.state?(expected_state)).to eq(true), message
  end

  # Set of standard checks
  #
  #   Is our current state == expected_state
  #   We can transition to back
  #   We can transition to next
  #   Fire next
  #
  def expect_state_canback_cannext_and_next!(journey, expected_state, message = nil)
    expect_state_matches(journey, expected_state, message)

    expect(journey.can_back?).to eq(true), "Expected can_back?  to be true"
    expect(journey.can_next?).to eq(true), "Expected can_next?  to be true"

    journey.next!
  end
end
