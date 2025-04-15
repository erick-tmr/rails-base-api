class StatusController < ApplicationController
  def index
    checks = {
      database: :error
    }
    http_status = :service_unavailable # Default to 503

    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      checks[:database] = :ok
      http_status = :ok
    rescue StandardError => e
      Rails.logger.error("Database health check failed: #{e.message}")
    end

    response_payload = {
      status: http_status == :ok ? :ok : :error,
      timestamp: Time.zone.now.iso8601,
      checks: checks
    }

    render json: response_payload, status: http_status
  end
end
