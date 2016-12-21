require 'rails_helper'

module DatashiftJourney
  RSpec.describe Collector::Collector, type: :model do
    context('Empty') do
      let(:collector) { create(:collector, state: :contact_details) }

      it { is_expected.to have_many(:form_fields).dependent(false) }
      it { is_expected.to have_many(:data_nodes).dependent(:destroy) }

      it 'can create a PageState to associated with a state and fields', duff: true do
        business_details_form = Collector::PageState.new(
          form_name: 'BusinessDetailsForm',
        )

        expect(business_details_form).to be_valid
      end

      it 'can save nodes for any given PageState and Field', duff: true do
        name_field = Collector::FormField.new(
          page_state: create(:collector_page_state),
          field: :name,
          field_presentation: 'Enter your Name',
          field_type: :string
        )

        expect(name_field).to be_valid

        collector.form_fields << name_field
        collector.save
        collector.reload
        expect(collector.form_fields.size).to eq 1
      end
    end

    context('Populated') do
      let(:collector) { create(:collector) }

      let(:page_state) { Collector::PageState.create(form_name: 'BusinessDetailsForm') }

      let(:page_snippet) {
        Collector::FieldSnippet.create(
            form_field: page_state,
            snippet: Collector::Snippet.create(raw_text: 'Enter your Company Name')
        )
      }

      let(:form_field) do
        Collector::FormField.create(
          page_state: page_state,
          field: :company_name,
          field_presentation: 'Enter your Company Name',
          field_type: :string
        )
      end
      let(:email_form_field) do
        Collector::FormField.create(
          page_state: page_state,
          field: :company_email,
          field_presentation: 'Enter your Company Email',
          field_type: :string
        )
      end

      context('PageState Fields') do
        before(:each) do
          collector.form_fields << form_field
        end

        it 'returns the node for a given PageState and Field', duff: true do
          node = collector.node_for_form_and_field('BusinessDetailsForm', 'company_name')
          expect(node).to be_a Collector::CollectorDataNode
        end

        it 'can store multiple Fields against the same PageState' do
          collector.form_fields << Collector::FormField.create(
            page_state: page_state,
            field: :company_email,
            field_presentation: 'Enter your Company Email',
            field_type: :string
          )

          collector.reload
          expect(collector.form_fields.size).to eq 2
        end
      end

      context('Populated - Data Nodes') do
        it 'can store store data against a Field in a DataNode' do
          email = FFaker::Internet.email
          collector.data_nodes.create(form_field: email_form_field, field_value: email)

          collector.reload
          expect(collector.form_fields.size).to eq 1

          expect(collector.form_fields.first.page_state.form_name).to eq 'BusinessDetailsForm'

          data_nodes = collector.nodes_for_form('BusinessDetailsForm')

          expect(data_nodes).to be_a Array
          expect(data_nodes.size).to eq 1

          expect(data_nodes.first.field_value).to eq email
        end
      end
    end
  end
end
