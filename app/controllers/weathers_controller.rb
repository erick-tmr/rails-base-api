class WeathersController < ApplicationController
  API_KEY = "3fc9cb54394cc7ad0010daa12eb9e286"

  def city
    city = city_params[:city]
    http_client = JsonHttpClient.new("https://api.openweathermap.org/data/2.5")

    begin
      response = http_client.connection.get("weather", { q: city, appid: API_KEY })

      unless response.success?
        Rails.logger.error("Error fetching post, body: #{response.body} status: #{response.status}")

        return render json: { error: response.body }, status: :unprocessable_entity
      end
    rescue Faraday::Error => e
      Rails.logger.error("Error fetching post: #{e.message}")

      return render json: { error: e.message }, status: :unprocessable_entity
    end

    kelvin_temperature = response.body.dig("main", "temp")

    if kelvin_temperature.nil?
      Rails.logger.error("Error fetching post: #{e.message}")

      return render json: { error: e.message }, status: :unprocessable_entity
    end

    temp_converter = TemperatureConverter.new(kelvin_temperature)

    api_response = {
      city: city,
      temperature: {
        kelvin: temp_converter.kelvin,
        celsius: temp_converter.celsius,
        fahrenheit: temp_converter.fahrenheit
      }
    }

    render json: api_response, status: :ok
  end

  private

  def city_params
    params.permit(:city)
  end
end
