# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      # ThirdPartyService is a service that interacts with third-party AI systems
      class ThirdPartyService < Decidim::Ai::SpamDetection::Service
        # classify calls the third party AI system to classify content
        # @param text [String] Content to classify
        # @param klass [String] Stringified klass of reportable
        # @return nil
        def classify(text, organization_host = "", klass = "")
          text = formatter.cleanup(text)
          return if text.blank?

          @registry.each do |strategy|
            strategy.classify(text, organization_host, klass)
          end
        end
      end
    end
  end
end
