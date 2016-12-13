require 'rails_helper'

module DatashiftJourney
  RSpec.describe Models::Collector, type: :model do

    context("Empty") do

      let(:collector) { create(:collector, state: :contact_details) }

      it { is_expected.to have_many(:form_fields).dependent(false) }
      it { is_expected.to have_many(:collector_data_nodes).dependent(:destroy) }

      it 'can create a Form to associated with a state and fields', duff: true do

        business_details_form = Models::Form.new(
            form: 'BusinessDetailsForm',
            presentation: "Enter the details of your Business",
        )

        expect(business_details_form).to be_valid
      end

      it 'can save nodes for any given Form and Field', duff: true do

        name_field = Models::FormField.new(
          form: create(:form),
          field: :name,
          field_presentation: "Enter your Name",
          field_type: :string
        )

        expect(name_field).to be_valid

        collector.form_fields << name_field
        collector.save
        collector.reload
        expect(collector.form_fields.size).to eq 1
      end
    end

    context("Populated") do
      let(:collector) { create(:collector) }

      before(:each) do

        f = Models::Form.create(form: 'BusinessDetailsForm', presentation: "Enter your Company Name")

        collector.form_fields << Models::FormField.create(
          form: f,
          field: :company_name,
          field_presentation: "Enter your Company Name",
          field_type: :string,
        )
      end

      it 'return s the node for a given Form and Field', duff: true do
        node = collector.nodes_for_form_and_field('BusinessDetailsForm', 'company_name').first
        expect(node).to be_aModels::FormField
      end

      it 'can store multiple Fields against the same Form' do

        collector.form_fields << Models::FormField.create(
          form: 'BusinessDetailsForm',
          field: :company_phone_number,
          field_presentation: "Enter your Company Email",
          field_type: :string,
          field_value:  FFaker::Internet.email
        )

        collector.reload
        expect(collector.form_fields.size).to eq 2

        expect(collector.nodes_for_form('BusinessDetailsForm').size).to eq 2
      end

      it 'can store store data against a Field in a DataNode' do

        collector.data_nodes << Models::CollectorDataNode.create(form_field: company_form_field,
                                                                 field_value: FFaker::Internet.email)

        collector.reload
        expect(collector.form_fields.size).to eq 2

        expect(collector.nodes_for_form('BusinessDetailsForm').size).to eq 2
      end
    end
  end
end

