# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in decidim-ai_third_party.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "rubocop", "~> 1.21"

gem "decidim-ai", git: "https://github.com/OpenSourcePolitics/decidim-module-ai.git", branch: "feat/third_party_service"

group :test do
  gem "byebug"
  gem "decidim-dev", "~> 0.29.0"
  gem "webmock"
end
