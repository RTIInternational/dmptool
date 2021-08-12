# frozen_string_literal: true

# This Job sends a notification (the JSON version of the Plan) out to the specified
# subscriber.
class NotifySubscriberJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    # TODO: We're currently only 'subscribing' the DMP ID service to plans.
    #       We can build out the rest of this if we add other subscriber types
    #       e.g. allowing an api_client associated with an Org's internal
    #       data curation or research project management systems
    case subscription.subscriber_type
    when "ApiClient"
      api_client = subscription.subscriber
      dmp_id_svc = api_client.name.downcase == DmpIdService.scheme_name.downcase

      # If the ApiClient is the DMP ID service then update the DMP ID metadata
      if DmpIdService.minting_service_defined? && dmp_id_svc
        Rails.logger.info "Sending #{api_client.name} the updated DMP ID metadata \
                          for Plan #{subscription.plan.id}"

        DmpIdService.minter.update_dmp_id(plan: self)

      elsif !dmp_id_svc
        # As long as this isn't the DMP ID service, send the update directly to the callback
        # Maybe just use HTTParty for this
      end
    else
      # Maybe just use HTTParty for this if we ever want to subscribe a different model
      # like a User or Org
    end

    subscription.update(last_notified: Time.now)
  rescue StandardError => e
    # Something went terribly wrong, so note it in the logs since this runs outside the
    # regular Rails thread that the application is using
    Rails.logger.error "NotifySubscriberJob.perform failed for \
                        Subscription: #{subscription.inspect}"
    Rails.logger.error "NotifySubscriberJob.perform - #{e.message}"
    Rails.logger.error e.backtrace
  end
end
