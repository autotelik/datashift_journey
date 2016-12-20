FactoryGirl.define do
  factory :collector_page_state, class: DatashiftJourney::Collector::PageState do

    form_name FFaker::Book.title

  end

end
