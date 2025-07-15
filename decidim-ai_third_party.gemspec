# frozen_string_literal: true

require_relative "lib/decidim/ai_third_party/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-ai_third_party"
  spec.version = Decidim::AiThirdParty::VERSION
  spec.authors = ["Quentin Champenois"]
  spec.email = ["quentin@opensourcepolitics.eu"]

  spec.summary = "Extend the Decidim AI module with third party AI system strategy"
  spec.description = "This gem extends the Decidim AI module to support third-party AI systems, allowing for more flexible and powerful AI integrations within the Decidim platform. It provides a strategy for integrating with external AI services, enhancing the capabilities of Decidim's AI features."

  spec.homepage = "https://github.com/OpenSourcePolitics/decidim-ai_third_party"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # spec.add_dependency 'decidim-ai', '~> 0.30.1'
  spec.add_development_dependency "rspec", "~> 3.2"
end
