class PostTestsController < ApplicationController
  def index
    posts = PostTest.all

    render json: posts, status: :ok
  end

  def create
    base_url = "https://jsonplaceholder.typicode.com"
    http_client = JsonHttpClient.new(base_url)

    begin
      response = http_client.connection.get("/posts/1")

      unless response.success?
        Rails.logger.error("Error fetching post, body: #{response.body} status: #{response.status}")

        return render json: { error: response.body }, status: :unprocessable_entity
      end
    rescue Faraday::Error => e
      Rails.logger.error("Error fetching post: #{e.message}")

      return render json: { error: e.message }, status: :unprocessable_entity
    end

    post = PostTest.new(text: "Text", json_response: response.body)

    if post.save
      render json: post, status: :created
    else
      render json: { error: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def real_post
    base_url = "https://jsonplaceholder.typicode.com"
    http_client = JsonHttpClient.new(base_url)
    payload = { title: "test", body: "test body", userId: 1 }

    begin
      response = http_client.connection.post("/posts") do |req|
        req.headers["Content-Type"] = "application/json; charset=UTF-8"
        req.body = payload.to_json
      end

      if response.success?
        render json: response.body, status: response.status
      else
        Rails.logger.error("Error posting to JSONPlaceholder, body: #{response.body} status: #{response.status}")

        error_body = JSON.parse(response.body)
        render json: { error: error_body }, status: response.status
      end
    rescue Faraday::Error => e
      Rails.logger.error("Faraday error posting to JSONPlaceholder: #{e.message}")
      render json: { error: e.message }, status: :service_unavailable
    rescue JSON::ParserError => e
      Rails.logger.error("Error parsing JSON response from JSONPlaceholder: #{e.message}")
      render json: { error: "Invalid JSON response received from external API" }, status: :internal_server_error
    end
  end
end
