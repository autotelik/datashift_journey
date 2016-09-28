class AddReviewableToJourneyPlan < ActiveRecord::Migration
  def change
    decorate_class = DatashiftJourney.journey_plan_class.name.tableize.tr('/', '_')

    add_column decorate_class, :under_review, :boolean, default: false
    add_column decorate_class, :submitted_at, :datetime
    add_column decorate_class, :completed_at, :datetime, index: true
  end
end
