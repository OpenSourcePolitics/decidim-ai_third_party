# Decidim::AiThirdParty

Extends the Decidim module AI to support third-party AI providers. This gem helps to implement any OpenAI compatible API providers. 

## Installation


### Add the gem dependency
Install the gem and add to the application's Gemfile by executing:

    $ bundle add decidim-ai
    $ bundle add decidim-ai_third_party

### Add the required jobs manually
Once gem is installed in the Decidim application, you need to add manually the two custom jobs `Decidim::Ai::SpamDetection::ThirdParty::GenericSpamAnalyzerJob` and `Decidim::Ai::SpamDetection::ThirdParty::UserSpamAnalyzerJob`

For generic spam detection:
* Create a new file `app/jobs/decidim/ai/spam_detection/third_party/generic_spam_analyzer_job.rb`
* Copy the content of file ./examples/generic_spam_analyzer_job.rb into the new file

For user spam detection:
* Create a new file `app/jobs/decidim/ai/spam_detection/third_party/user_spam_analyzer_job.rb`
* Copy the content of file ./examples/user_spam_analyzer_job.rb into the new file

### Configure AI module through the Decidim initializer

You need to configure the AI module in the Decidim initializer file `config/initializers/decidim_ai.rb`. An initializer example is available at ./examples/decidim_ai.rb

### Add environment variables in Rails secrets

You need to add the environment variables in the Rails secrets file `config/secrets.yml` :

```yaml
decidim_default:
  ai:
      endpoint: <%= Decidim::Env.new("DECIDIM_AI_ENDPOINT").to_s %>
      secret: <%= Decidim::Env.new("DECIDIM_AI_SECRET").to_s %>
      basic_auth: <%= Decidim::Env.new("DECIDIM_AI_BASIC_AUTH").to_s %>
      reporting_user_email: <%= Decidim::Env.new("DECIDIM_AI_REPORTING_USER_EMAIL").to_s %>
      resource_score_threshold: <%= Decidim::Env.new("DECIDIM_AI_RESOURCE_SCORE_THRESHOLD", 0.5).to_f %>
      user_score_threshold: <%= Decidim::Env.new("DECIDIM_AI_USER_SCORE_THRESHOLD", 0.5).to_f %>
```

### Create the reporting user

?? This step is very important, if the user `Decidim::Ai::SpamDetection.reporting_user_email` does not exist, it will crash quietly when the spam detection job is executed.

```bash
DECIDIM_AI_REPORTING_USER_EMAIL="<REPORTING_USER_TO_CREATE>" bundle exec rake decidim:ai:spam:create_reporting_user
```