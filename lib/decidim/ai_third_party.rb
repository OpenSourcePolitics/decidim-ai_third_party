# frozen_string_literal: true

require "decidim/ai"

require_relative "ai_third_party/version"
require_relative "ai/spam_detection/openai/strategy"
require_relative "ai/spam_detection/ai_request_handler/strategy"
require_relative "ai/spam_detection/third_party_service"

module Decidim
  module AiThirdParty
    class Error < StandardError; end
  end
end
