FactoryBot.define do
  factory :form_field, class: DatashiftJourney::Collector::FormField do
    association  :form_definition
    name { 'BusinessDetailsForm' }
    category { :string }
    options {{}}
  end
end
