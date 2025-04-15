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
end
