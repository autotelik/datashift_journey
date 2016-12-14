module DatashiftJourney
  module Models

    # This stores a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class Form < ActiveRecord::Base

      self.table_name = 'dsj_forms'

      has_many :form_fields, dependent: :destroy

      has_many :data_nodes,
               through: :form_fields,
               class_name: "CollectorDataNode",
               foreign_key: :form_id,
               dependent: :destroy


    end
  end
end
