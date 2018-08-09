require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class Base < Spree::Calculator::Shipping::ActiveShipping::Base
        def carrier
          carrier_details = {
            key: @vendor.carriers['fedex_key'],
            password: @vendor.carriers['fedex_password'],
            account: @vendor.carriers['fedex_account'],
            login: @vendor.carriers['fedex_login'],
            test: @vendor.carriers['test_mode'],
            surcharges: @vendor.carriers['fedex_include_surcharges']
          }
          ::ActiveShipping::FedEx.new(carrier_details)
        end

        protected
        def max_weight_for_country(country)
          2400 # 150 lbs
        end
      end
    end
  end
end
