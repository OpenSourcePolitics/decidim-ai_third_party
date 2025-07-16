# frozen_string_literal: true

require 'spec_helper'

class ErrorResponse; end

RSpec.describe Decidim::Ai::SpamDetection::AiRequestHandler::Strategy do
  let(:strategy) { described_class.new(endpoint: "https://example.com/api", secret: "secret_token") }
  let(:content) { 'Sample content to classify' }
  let(:organization_host) { 'example.org' }
  let(:klass) { 'Decidim::Comments::Comment' }
  let(:uri) { URI('https://example.com/api') }
  let(:http) { instance_double(Net::HTTP) }
  let(:request) { instance_double(Net::HTTP::Post) }
  let(:response) { instance_double(Net::HTTPSuccess) }


  before do
    allow(Rails).to receive(:application).and_return(double(secrets: { decidim: { }}))
    allow(Rails).to receive(:logger).and_return(double("Rails.logger", info: double(send: ""), error: nil))
    allow(strategy).to receive(:system_log)
    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:use_ssl=)
    allow(Net::HTTP::Post).to receive(:new).and_return(request)
    allow(request).to receive(:[]=)
    allow(request).to receive(:body=)
    allow(http).to receive(:request).and_return(response)
  end

  describe '#classify' do
    context 'when the third-party request is successful' do
      let(:response) { Net::HTTPSuccess.new(2, 200, "OK") }

      before do
        allow(response).to receive(:body).and_return({spam: 'SPAM'}.to_json)
      end

      it 'returns a score' do
        expect(strategy.classify(content, organization_host, klass)).to eq(strategy.score)
      end
    end

    context 'when the third-party request returns an invalid format' do
      let(:response) { Net::HTTPSuccess.new(2, 200, "OK") }

      before do
        allow(response).to receive(:body).and_return({ 'spam' => 'INVALID RESPONSE' }.to_json)
      end

      it 'raises an InvalidOutputFormat error' do
        expect { strategy.classify(content, organization_host, klass) }.to raise_error(Decidim::Ai::SpamDetection::Openai::Strategy::InvalidOutputFormat)
      end
    end

    context 'when the third-party request raises an error' do
      before do
        allow(strategy).to receive(:third_party_request).and_raise(Decidim::Ai::SpamDetection::Openai::Strategy::ThirdPartyError.new('Error message'))
      end

      it 'raises a ThirdPartyError' do
        expect { strategy.classify(content, organization_host, klass) }.to raise_error(Decidim::Ai::SpamDetection::Openai::Strategy::ThirdPartyError)
      end
    end
  end

  describe '#third_party_request' do
    it 'makes a POST request to the third-party endpoint' do
      expect(http).to receive(:request).with(request)
      strategy.third_party_request(content, organization_host, klass)
    end
  end

  describe '#parse_http_response' do
    context 'when the response is successful' do
      let(:response) { Net::HTTPSuccess.new(2, 200, "OK") }

      before do
        allow(response).to receive(:body).and_return({ 'spam' => 'SPAM' }.to_json)
      end
      it 'parses the response body' do
        expect(strategy.parse_http_response(response)).to eq({ 'spam' => 'SPAM' })
      end
    end

    context 'when the response is forbidden' do
      let(:response) { Net::HTTPForbidden.new(2, 401, "Forbidden") }

      it 'raises a Forbidden error' do
        expect { strategy.parse_http_response(response) }.to raise_error(Decidim::Ai::SpamDetection::Openai::Strategy::Forbidden)
      end
    end

    context 'when the response times out' do
      let(:response) { Net::HTTPRequestTimeout.new(2, 408, "Timeout") }

      before do
        allow(response).to receive(:body).and_return("Timeout occurred")
      end
      it 'raises a TimeoutError' do
        expect { strategy.parse_http_response(response) }.to raise_error(Decidim::Ai::SpamDetection::Openai::Strategy::TimeoutError)
      end
    end
  end

  describe '#third_party_content' do
    it 'returns the spam value from the body' do
      body = { 'spam' => 'ham' }
      expect(strategy.third_party_content(body)).to eq('ham')
    end

    it 'returns an empty string if the body is blank' do
      expect(strategy.third_party_content(nil)).to eq('')
    end
  end

  describe '#payload' do
    it 'returns the payload hash' do
      expected_payload = { text: content, type: klass }
      expect(strategy.payload(content, klass)).to eq(expected_payload)
    end
  end
end
