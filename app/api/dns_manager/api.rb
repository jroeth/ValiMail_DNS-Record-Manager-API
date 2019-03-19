module DnsManager
  class API < Grape::API
    include Grape::Kaminari

    content_type :json, "application/json;charset=UTF-8"
    format :json

    helpers DnsManager::ApiHelpers

    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({ error: "404 Not found." }, 404)
    end

    if Rails.env.production?
      rescue_from :all do |e|
        Rails.logger.error e.message + "\n " + e.backtrace.join("\n ")
        error!({ message: e.message }, 400)
      end
    end
  end
end
