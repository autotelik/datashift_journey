module DatashiftJourney

  class PageStatePresenter < JsonPresenters

    def self.minimal_hash(page_state)
      node = hash_for(page_state, %w(id form_name))
      node
    end

    def self.minimal_hash_for_collection(collection)
      collection.map { |item| minimal_hash(item) }
    end

  end
end
