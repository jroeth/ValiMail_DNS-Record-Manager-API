module DnsManager
  class API < Grape::API
    include Grape::Kaminari

    content_type :json, "application/json;charset=UTF-8"
    format :json
    default_error_formatter :json
    cascade false

    helpers DnsManager::ApiHelpers

    rescue_from ActiveRecord::RecordNotFound do |e|
      Rails.logger.error e.message + "\n " + e.backtrace.join("\n ")
      error!({ error: "404 Record not found." }, 404)
    end

    rescue_from ActionController::RoutingError do |e|
      Rails.logger.error e.message + "\n " + e.backtrace.join("\n ")
      error!({ error: "404 Path not found." }, 404)
    end

    rescue_from :all do |e|
      Rails.logger.error e.message + "\n " + e.backtrace.join("\n ")
      error!({ error: e.message }, 400)
    end

    route :any, '*path' do
      error!({ error:  'Not Found (API)',
               detail: "No such route '#{request.path}'",
               status: '404' }.to_json, 404)
    end
  end
end
