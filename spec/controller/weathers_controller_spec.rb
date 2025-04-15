require 'rails_helper'

describe WeathersController, type: :controller do
  describe '/city' do
    context 'when request to weather api succeeds' do
      let(:api_mock_response) { { "main" => { "temp" => 297.79 }  } }
      let(:city) { "Sao Paulo" }

      it 'returns a json response with 200 code' do
        http_mock = double("JsonHttpClient")
        faraday_conn_mock = double("Faraday Conection")
        faraday_response_mock = double("Faraday Response")
        expect(http_mock).to receive(:connection).and_return(faraday_conn_mock)
        expect(faraday_conn_mock).to receive(:get).and_return(faraday_response_mock)
        expect(faraday_response_mock).to receive(:success?).and_return(true)
        expect(faraday_response_mock).to receive(:body).and_return(api_mock_response)
        expect(JsonHttpClient).to receive(:new).and_return(http_mock)

        get :city, params: { city: city }

        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(response.content_type).to include("application/json")
        expect(response.body).to eq({ city: city, temperature: { kelvin: 297.79, celsius: 24.64, fahrenheit: 76.35 } }.to_json)
      end
    end
  end
end
