require 'rspec/expectations'

RSpec::Matchers.define :match_state do |expected|
  match do |plan|
    expect(plan.state_name.to_s).to eq(expected.to_s)
    expect(plan.state).to eq(expected.to_s)
    expect(plan.state?(expected)).to eq(true)
  end
end

RSpec::Matchers.define :match_state_can_back_and_fwd do |expected|
  match do |plan|
    expect(plan.state_name.to_s).to eq(expected.to_s)
    expect(plan.can_back?).to eq(true), 'Expected can_back?  to be true'
    expect(plan.can_skip_fwd?).to eq(true), 'Expected can_skip_fwd?  to be true'
  end
end

RSpec::Matchers.define :match_state_can_back do |expected|
  match do |plan|
    expect(plan.state_name.to_s).to eq(expected.to_s)
    expect(plan.can_back?).to eq(true), 'Expected can_back?  to be true'
  end
end
