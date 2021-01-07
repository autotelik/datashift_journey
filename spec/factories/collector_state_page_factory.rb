=begin
FactoryGirl.define do
  factory :collector_page_state, class: DatashiftJourney::Collector::PageState do
    form_name { FFaker::Book.title }

    trait :with_snippets do
      after(:create) do |object|
        object.snippets = create_list(:snippet, 3)
        object.save!
      end
    end
  end
end
=end
