module DnsManager
  module ApiHelpers
    extend Grape::API::Helpers

    def permitted_params
      declared(params, include_missing: false)
    end

    def resource_error!(resource)
      error!({ error: user.errors.full_messages.join(', ') }, 422)
    end
  end
end
