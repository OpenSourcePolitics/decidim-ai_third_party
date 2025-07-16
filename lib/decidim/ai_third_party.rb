# frozen_string_literal: true

require "decidim/ai"

require_relative "ai_third_party/version"
require_relative "ai/spam_detection/openai/strategy"
require_relative "ai_third_party/strategy/third_party"
require_relative "ai_third_party/strategy/scaleway"

module Decidim
  module AiThirdParty
    class Error < StandardError; end
    # Your code goes here...
  end
end
