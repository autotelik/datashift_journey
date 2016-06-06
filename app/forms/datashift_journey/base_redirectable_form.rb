module DatashiftJourney
  class BaseRedirectableForm < BaseForm

    attr_accessor :redirection_url
    attr_accessor :redirect
    alias redirect? redirect

  end
end
