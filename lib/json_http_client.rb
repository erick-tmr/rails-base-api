class JsonHttpClient
  attr_reader :connection

  def initialize(base_url)
    @connection = Faraday.new(url: base_url) do |faraday|
      faraday.request :json
      faraday.request :retry, {
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2
      }
      faraday.response :json
      faraday.adapter Faraday.default_adapter
      faraday.response :logger
    end
  end
end
