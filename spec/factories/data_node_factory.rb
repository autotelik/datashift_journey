FactoryGirl.define do
  factory :form_field, class: DatashiftJourney::Models::FormField do

    form 'BusinessDetailsForm'
    field :company_name
    field_presentation "Enter your Company Name"
    field_type :string
    field_value  "Acme Ltd"

  end
end

