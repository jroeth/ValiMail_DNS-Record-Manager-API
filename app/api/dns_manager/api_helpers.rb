module DnsManager
  module ApiHelpers
    extend Grape::API::Helpers

    params :pagination do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 20
    end

    # def current_user
    #   # Implement your API authentication here
    #   # @current_user ||= User.authenticate!(env)
    # end
    #
    # def authenticate!
    #   error!({ error: "401 Unauthorized." }, 401) unless current_user
    # end

    def permitted_params
      declared(params, include_missing: false)
    end

    def resource_error!(resource)
      error!({ error: user.errors.full_messages.join(', ') }, 422)
    end
  end
end
