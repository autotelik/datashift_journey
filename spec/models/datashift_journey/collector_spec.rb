require 'rails_helper'

module DatashiftJourney
  RSpec.describe Models::Collector, type: :model do

    context("Empty") do

      let(:collector) { create(:collector) }

      it { is_expected.to have_many(:collector_data_nodes).dependent(:destroy) }

      it 'can save nodes for any given Form and Field', duff: true do
        company_node = DatashiftJourney::Models::DataNode.new(
          form_name: 'BusinessDetailsForm',
          field: :company_name,
          field_presentation: "Enter your Company Name",
          field_type: :string,
          field_value:  "Acme Ltd",
        )

        expect(company_node).to be_valid

        collector.data_nodes << company_node
        collector.save
        collector.reload
        expect(collector.data_nodes.size).to eq 1
      end
    end

    context("Populated") do
      let(:collector) { create(:collector) }

      before(:each) do
        collector.data_nodes << DatashiftJourney::Models::DataNode.create(
          form_name: 'BusinessDetailsForm',
          field: :company_name,
          field_presentation: "Enter your Company Name",
          field_type: :string,
          field_value:  "Acme Ltd",
        )
      end

      it 'return s the node for a given Form and Field', duff: true do
        node = collector.nodes_for_form_and_field('BusinessDetailsForm', 'company_name').first
        expect(node).to be_a DatashiftJourney::Models::DataNode
      end

      it 'can store multiple Fields against trhe same Form' do

        collector.data_nodes << DatashiftJourney::Models::DataNode.create(
          form_name: 'BusinessDetailsForm',
          field: :company_phone_number,
          field_presentation: "Enter your Company Email",
          field_type: :string,
          field_value:  FFaker::Internet.email
        )

        collector.reload
        expect(collector.data_nodes.size).to eq 2

        expect(collector.nodes_for_form('BusinessDetailsForm').size).to eq 2
      end
    end
  end
end

