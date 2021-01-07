=begin
require 'rails_helper'
require 'swagger_helper'

require 'page_state'

module DatashiftJourney
  describe Collector::PageState do

    path '/api/v1/page_states' do

      post 'Creates a page_state' do
        tags 'PageState'
        consumes 'application/json', 'application/xml'
        parameter name: :page_state, in: :body, schema: {
            type: :object,
            properties: {
                form_name: { type: :string }
            },
            required: [ 'form_name' ]
        }

        response '201', 'page_state created' do
          let(:page_state) { { form_name: 'BrandNewPage' } }

          #before do |example|
            # pp example.metadata
          #end

          pending("can rwsag support modules?")
          # To fix - does not seem to handle namespaces
          #   Failure/Error: raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it" unless from_mod.const_defined?(const_name, false)
          #   LoadError:
          #     Unable to autoload constant PageState, expected /data/users/thomas.statter/SoftwareDev/git/datashift_journey/lib/datashift_journey/collector/page_state.rb to define it
          #run_test!
        end

        response '422', 'invalid request' do
          let(:page_state) { { for: 'foo' } }
          #run_test!
        end
      end
    end

  end
end
=end
