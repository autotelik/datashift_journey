class CreateJourneyPLans < ActiveRecord::Migration
  def change
    create_table :datashift_state_journey_plans do |t|
      t.string      :state
      t.integer     :status, null: false, default: 0, index: true
      t.boolean     :under_review, default: false
      t.datetime    :submitted_at
      t.datetime    :completed_at
      t.string      :token, unique: true

      t.timestamps null: false
    end

    add_index :datashift_state_journey_plans, :state
    add_index :datashift_state_journey_plans, :completed_at
  end
end
