require "datashift_state/engine"

module DatashiftState

  def self.table_name_prefix
    "datashift_"
  end

end

require "datashift_state/exceptions"
require "datashift_state/services/address_lookup"
