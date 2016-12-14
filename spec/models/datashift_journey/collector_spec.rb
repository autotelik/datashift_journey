require 'rails_helper'

module DatashiftJourney
  RSpec.describe Models::Collector, type: :model do

    context("Empty") do

      let(:collector) { create(:collector, state: :contact_details) }

      it { is_expected.to have_many(:form_fields).dependent(false) }
      it { is_expected.to have_many(:data_nodes).dependent(:destroy) }

      it 'can create a Form to associated with a state and fields', duff: true do

        business_details_form = Models::Form.new(
            form_name: 'BusinessDetailsForm',
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

      let(:form) { Models::Form.create(form_name: 'BusinessDetailsForm', presentation: "Enter your Company Name") }

      let(:form_field) do
        Models::FormField.create(
            form: form,
            field: :company_name,
            field_presentation: "Enter your Company Name",
            field_type: :string,
        )
      end
      let(:email_form_field) do
        Models::FormField.create(
            form: form,
            field: :company_email,
            field_presentation: "Enter your Company Email",
            field_type: :string,
        )
      end

      context("Form Fields") do

        before(:each) do
          collector.form_fields << form_field
        end

        it 'returns the node for a given Form and Field', duff: true do
          node = collector.node_for_form_and_field('BusinessDetailsForm', 'company_name')
          expect(node).to be_a Models::CollectorDataNode
        end

        it 'can store multiple Fields against the same Form' do

          collector.form_fields << Models::FormField.create(
              form: form,
              field: :company_email,
              field_presentation: "Enter your Company Email",
              field_type: :string,
          )

          collector.reload
          expect(collector.form_fields.size).to eq 2
        end
      end

      context("Populated - Data Nodes") do

        it 'can store store data against a Field in a DataNode' do
          email = FFaker::Internet.email
          collector.data_nodes.create(form_field: email_form_field, field_value:email)

          collector.reload
          expect(collector.form_fields.size).to eq 1

          expect(collector.form_fields.first.form.form_name).to eq 'BusinessDetailsForm'

          data_nodes = collector.nodes_for_form('BusinessDetailsForm')

          expect(data_nodes).to be_a Array
          expect(data_nodes.size).to eq 1

          expect(data_nodes.first.field_value).to eq email
        end
      end

    end

  end
end

