# Example Usage
#
# Templates::RailsForm.reform_style_template % [model, form_id]
#
module CopyKit
  module Templates
    module RailsForm
      def self.template
        # n.b %% escapes %
        @rails_form_template ||= "<%%= form.fields_for :%s do |%s| %%>"
      end

      def self.reform_style_template
        @reform_style_template ||= "<%%= form.fields_for @form.model do |%s| %%>"
      end
    end
  end
end
