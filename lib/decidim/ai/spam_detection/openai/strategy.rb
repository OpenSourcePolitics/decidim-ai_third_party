# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Openai
        # Strategy to classify content as spam or not spam using a third-party AI service which implements OpenAI API standard format.
        class Strategy < Decidim::Ai::SpamDetection::Strategy::Base
          class ThirdPartyError < StandardError; end

          class InvalidOutputFormat < ThirdPartyError; end

          class InvalidEntity < ThirdPartyError; end

          class Forbidden < ThirdPartyError; end

          class TimeoutError < ThirdPartyError; end

          OUTPUT = %w(SPAM NOT_SPAM).freeze

          def initialize(options = {})
            super
            @endpoint = Rails.application.secrets.dig(:decidim, :ai, :endpoint)
            @secret = Rails.application.secrets.dig(:decidim, :ai, :secret)
            @options = options
          end

          def log
            return "AI system didn't marked this content as spam" if score <= score_threshold

            "AI system marked this as spam"
          end

          def classify(content)
            system_log("Starting classification...")
            res = third_party_request(content)
            body = res.body

            system_log("Received response from third party service: #{body}")
            raise InvalidEntity, res unless res.is_a?(Net::HTTPSuccess)

            content = third_party_content(body)
            raise InvalidOutputFormat, "Third party service response isn't valid JSON" unless valid_output_format?(content)

            @category = content.downcase
            system_log("Spam : #{score}.")
            score
          rescue InvalidEntity, InvalidOutputFormat => e
            system_log(e, level: :error)
            score
          end

          def third_party_request(content)
            uri = URI(@endpoint)
            payload = payload(content).to_json
            system_log("Sending request to third party service: #{payload}")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.post(uri.path, payload, headers)
          end

          def headers
            @headers ||= {
              "Authorization" => "Bearer #{@secret}",
              "Content-Type" => "application/json",
              "Accept" => "application/json"
            }
          end

          def payload(content)
            {
              model: @options[:model],
              messages: [
                {
                  role: "system",
                  content: @options[:system_message]
                },
                {
                  role: "user",
                  content:
                }
              ],
              max_tokens: @options[:max_tokens],
              temperature: @options[:temperature],
              top_p: @options[:top_p],
              presence_penalty: @options[:presence_penalty],
              stream: @options[:stream]
            }
          end

          # This method should be implemented by the subclass depending on the third-party service
          def third_party_content(body)
            return [] if body.blank?

            choices = JSON.parse(body)&.fetch("choices", [])
            choices.first&.dig("message", "content")
          end

          def score
            @score ||= @category.presence == "spam" ? 1 : 0
          end

          private

          attr_reader :options

          def valid_output_format?(output)
            output.present? && output.is_a?(String) && output.in?(OUTPUT)
          end

          def score_threshold
            return Decidim::Ai::SpamDetection.user_score_threshold if name == :third_party_user

            Decidim::Ai::SpamDetection.resource_score_threshold
          end

          def system_log(message, level: :info)
            Rails.logger.send(level, "[decidim-ai] #{self.class.name} - #{message}")
          end
        end
      end
    end
  end
end
