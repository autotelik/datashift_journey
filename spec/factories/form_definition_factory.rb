FactoryBot.define do

  factory :form_definition, class:  DatashiftJourney::Collector::FormDefinition do
    state { "deployment" }
    klass { "DeploymentForm" }
    #state: "image_type"
    # klass: "ImageTypeForm"

    # state: "default_predicator"
    # klass: "DefaultPredicatorForm"
  end

=begin
  factory :form, class: DatashiftJourney::Collector::PageState do
    form_name 'Home AddressForm'
    presentation 'Please Enter your Home Address'
  end
=end
end
