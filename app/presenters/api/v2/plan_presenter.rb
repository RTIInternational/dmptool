# frozen_string_literal: true

module Api

  module V2

    class PlanPresenter

      attr_reader :data_contact, :contributors, :costs, :client

      def initialize(plan:, client:)
        @contributors = []
        return unless plan.present?

        @helpers = Rails.application.routes.url_helpers
        @plan = plan
        @client = client

        # Attach the first data_curation role as the data_contact, otherwise
        # add the contributor to the contributors array
        @plan.contributors.each do |contributor|
          @data_contact = contributor if contributor.data_curation? && @data_contact.nil?
          @contributors << contributor
        end

        @data_contact = @plan.owner unless @data_contact.present?
        @costs = plan_costs(plan: @plan)
      end

      # Extract the ARK or DOI for the DMP OR use its URL if none exists
      def identifier
        doi = @plan.doi
        return doi if doi.present?

        # if no DOI then use the URL for the API's 'show' method
        Identifier.new(value: @helpers.api_v2_plan_url(@plan))
      end

      # Related identifiers for the Plan
      def links
        ret = {
          get: @helpers.api_v2_plan_url(@plan)
        }

p @client.inspect
p @plan.owner.access_token_for(external_service_name: @client.name.downcase)

        # If the plan is publicly visible or the request has permissions then include the PDF download URL
        if @plan.publicly_visible? ||
           (@client.is_a?(User) && @plan.owner_and_coowners.include?(@client)) ||
           (@client.is_a?(User) && @plan.org_id == @plan.owner&.org_id) ||
           (@client.is_a?(ApiClient) && @client.access_tokens.select { |t| t.active_for(@plan.owner) })
          ret[:download] = @helpers.api_v2_plan_url(@plan, format: :pdf)
        end
        ret
      end

      # Subscribers of the Plan
      def subscriptions
        @plan.subscriptions.map do |subscription|
          {
            actions: ["PUT"],
            name: subscription.subscriber.name,
            callback: subscription.callback_uri
          }
        end
      end

      def visibility
        @plan.visibility == "publicly_visible" ? "public" : "private"
      end

      private

      # Retrieve the answers that have the Budget theme
      def plan_costs(plan:)
        theme = Theme.where(title: "Cost").first
        return [] unless theme.present?

        # TODO: define a new 'Currency' question type that includes a float field
        #       any currency type selector (e.g GBP or USD)
        answers = plan.answers.includes(question: :themes).select do |answer|
          answer.question.themes.include?(theme)
        end

        answers.map do |answer|
          # TODO: Investigate whether question level guidance should be the description
          { title: answer.question.text, description: nil,
            currency_code: "usd", value: answer.text }
        end
      end

    end

  end

end
