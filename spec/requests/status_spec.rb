require 'rails_helper'

describe 'Status API', type: :request do
  describe 'GET /status' do
    context 'when the database connection is successful' do
      before do
        get '/status'
      end

      it 'returns status code 200 (OK)' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the overall status as ok' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:status]).to eq('ok')
      end

      it 'returns the database check status as ok' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:checks][:database]).to eq('ok')
      end

      it 'returns a timestamp' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:timestamp]).to be_present
        expect { Time.iso8601(json_response[:timestamp]) }.not_to raise_error
      end
    end

    context 'when the database connection fails' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).with("SELECT 1").and_raise(StandardError, "Simulated DB connection error")
        allow(Rails.logger).to receive(:error)
        get '/status'
      end

      it 'returns status code 503 (Service Unavailable)' do
        expect(response).to have_http_status(:service_unavailable)
      end

      it 'returns the overall status as error' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:status]).to eq('error')
      end

      it 'returns the database check status as error' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:checks][:database]).to eq('error')
      end

      it 'returns a timestamp' do
        json_response = JSON.parse(response.body).deep_symbolize_keys
        expect(json_response[:timestamp]).to be_present
        expect { Time.iso8601(json_response[:timestamp]) }.not_to raise_error
      end

      it 'logs the database error' do
        expect(Rails.logger).to have_received(:error).with(/Database health check failed: Simulated DB connection error/)
      end
    end
  end
end
