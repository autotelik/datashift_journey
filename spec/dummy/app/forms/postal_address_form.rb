class  PostalAddressForm < DatashiftJourney::Collector::BaseCollectorForm

  def params_key
    :postal_address
  end

  # Data collection performed by base class but if you need custom processing, the forms
  # fields are represented as a series of DataNode objects, with the actual data saved in :field_value 
  # 
  # collection :data_nodes do
  #   property :field_value
  # end

  # Example basic validation - has field been filled in :
  # validates :field_value, presence: true

end
