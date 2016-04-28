module DatashiftState

  class AbandonmentsController < ApplicationController

    include HighVoltage::StaticPage

    # idea is that here was can log/update DB with any useful info on
    # where/why user has abandoned, before we fwd them onto a relevant
    # static helper page (N.B served up from views/pages)

    def show
      logger.info('User has abandoned')
      super
    end
  end

end
