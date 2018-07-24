module Spree
  module ActiveShipping
    module FedexOverride
      def self.included(base)
        base.class_eval do
          def parse_rate_response(origin, destination, packages, response, options)
            xml = build_document(response, 'RateReply')

            success = response_success?(xml)
            message = response_message(xml)

            if success
              rate_estimates = xml.root.css('> RateReplyDetails').map do |rated_shipment|
                service_code = rated_shipment.at('ServiceType').text
                is_saturday_delivery = rated_shipment.at('AppliedOptions').try(:text) == 'SATURDAY_DELIVERY'
                service_type = is_saturday_delivery ? "#{service_code}_SATURDAY_DELIVERY" : service_code

                transit_time = rated_shipment.at('TransitTime').text if ['FEDEX_GROUND', 'GROUND_HOME_DELIVERY'].include?(service_code)
                max_transit_time = rated_shipment.at('MaximumTransitTime').try(:text) if service_code == 'FEDEX_GROUND'

                delivery_timestamp = rated_shipment.at('DeliveryTimestamp').try(:text)

                delivery_range = delivery_range_from(transit_time, max_transit_time, delivery_timestamp, options)

                currency = rated_shipment.at('RatedShipmentDetails/ShipmentRateDetail/TotalBaseCharge/Currency').text
                ::ActiveShipping::RateEstimate.new(origin, destination, ::ActiveShipping::FedEx.name,
                     self.class.service_name_for_code(service_type),
                     service_code: service_code,
                     total_price: rated_shipment.at(rates_amount).text.to_f,
                     currency: currency,
                     packages: packages,
                     delivery_range: delivery_range)
              end

              if rate_estimates.empty?
                success = false
                message = 'No shipping rates could be found for the destination address' if message.blank?
              end
            else
              rate_estimates = []
            end

            ::ActiveShipping::RateResponse.new(success, message,
                                               Hash.from_xml(response),
                                               rates: rate_estimates,
                                               xml: response,
                                               request: last_request,
                                               log_xml: options[:log_xml])
          end

          def rates_amount
            @options[:surcharges] ? 'RatedShipmentDetails/ShipmentRateDetail/TotalNetCharge/Amount' : 'RatedShipmentDetails/ShipmentRateDetail/TotalBaseCharge/Amount'
          end
        end
      end
    end
  end
end
