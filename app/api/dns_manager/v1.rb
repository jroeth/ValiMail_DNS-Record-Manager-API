module DnsManager
  class V1 < DnsManager::API
    version "v1", using: :path
    prefix :api

    get do
      { version: "v1" }
    end

    resource :zone do

      desc 'Return a Zone.'
      params do
        requires :id, type: Integer, desc: 'Zone ID.'
      end
      route_param :id do
        get do
          Zone.find(params[:id])
        end
      end

      desc 'Create a Zone.'
      params do
        requires :name, type: String, desc: 'Zone name.'
      end
      post do
        Zone.create!({
          name: params[:name]
        })
      end

      desc 'Delete a Zone.'
      params do
        requires :id, type: Integer, desc: 'Zone ID.'
      end
      delete ':id' do
        Zone.find(params[:id]).destroy
      end

    end

    add_swagger_documentation hide_format: true, api_version: "api/v1"
  end
end
