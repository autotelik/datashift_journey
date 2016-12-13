require 'rails_helper'

module DatashiftJourney
  RSpec.describe Models::Collector, type: :model do

    context("Empty") do

      let(:collector) { create(:collector) }

      it { is_expected.to have_many(:collector_form_fields).dependent(:destroy) }

      it 'can save nodes for any given Form and Field', duff: true do
        company_node = Models::FormField.new(
          form: 'BusinessDetailsForm',
          field: :company_name,
          field_presentation: "Enter your Company Name",
          field_type: :string,
          field_value:  "Acme Ltd",
        )

        expect(company_node).to be_valid

        collector.form_fields << company_node
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

