module DatashiftJourney

  class AbandonmentsController < ApplicationController

    include HighVoltage::StaticPage

    # idea is that here was can log/update DB with any useful info on
    # where/why user has abandoned, before we fwd them onto a relevant
    # static helper page (N.B served up from views/pages)

    def show
      logger.info('User has abandoned')

      # high voltage expects  id => name of page
      # params[:id] = params['page']

      super
    end
  end

end
