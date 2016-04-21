class CreateJourneyPlans < ActiveRecord::Migration
  def change

    puts  DatashiftState.journey_plan_class, DatashiftState.journey_plan_class.name.tableize

    decorate_class = DatashiftState.journey_plan_class.name.tableize.gsub('/', '_')

    add_column decorate_class, :state, :string
    add_column decorate_class, :under_review, :boolean, default: false
    add_column decorate_class, :submitted_at, :datetime
    add_column decorate_class, :completed_at, :datetime
    add_column decorate_class, :token, :string, unique: true

    add_index decorate_class, :state
    add_index decorate_class, :completed_at

=begin
      t.integer     :status, null: false, default: 0, index: true
      t.timestamps null: false
    end
=end
  end
end