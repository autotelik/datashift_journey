module StateMachines
    class StateSerializer < ActiveModel::Serializer
      attributes :name, :value, :initial
    end
end