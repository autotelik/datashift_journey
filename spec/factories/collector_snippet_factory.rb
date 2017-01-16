FactoryGirl.define do
  factory :snippet, class: DatashiftJourney::Collector::Snippet do
    raw_text { FFaker::Lorem.sentence }
  end

  factory :i18n_snippet, class: DatashiftJourney::Collector::Snippet do
    I18n_key :rspec_snippet_text
  end

end
