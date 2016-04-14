module DatashiftState

  class SortValidations

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def sort(order)
      # For each key in order, create a [key, value] pair from the hash.
      # Doing it this way instead of filtering the hash.to_a is O(n) vs O(n^2) without additional hash-probe mapping.

      # Also remove only the existing errors to be ordered later
      selected_pairs = order.map do |k|
        v = model.errors.delete(k)
        [k, v]
      end

      # For each pair create a surrogate ordering based on the `order`-index
      # (The surrogate value is only computed once, not each sort-compare step.
      # This is, however, an O(n^2) operation on-top of the sort.)
      sorted = selected_pairs.sort_by {|p| order.find_index(p.first) }

      sorted.each {|k, v| model.errors.set(k, v) }
    end

    private

    attr_writer :model

  end
end
