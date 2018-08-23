require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class TwoDayAm < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          I18n.t("fedex.two_day_am")
        end
      end
    end
  end
end
