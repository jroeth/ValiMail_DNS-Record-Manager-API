module DnsManager
  class V1 < DnsManager::API
    version "v1", using: :path
    prefix :api

    get do
      { version: "v1" }
    end


    resource :zone do

      desc 'Get a Zone.'
      params do
        requires :id, type: Integer, desc: 'Zone ID.'
      end
      route_param :id do
        get do
          Zone.find(params[:id])
        end
      end

      desc 'Get all Zones.'
      get do
        Zone.all
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

    resource :record do

      desc 'Get a Record.'
      params do
        requires :id, type: Integer, desc: 'Record ID.'
      end
      route_param :id do
        get do
          Record.find(params[:id])
        end
      end

      desc 'Get all Records.'
      get do
        Record.all
      end

      desc 'Get all Records for Zone.'
      params do
        requires :zone, type: Integer, desc: 'Zone ID.'
      end
      get do
        zone = Zone.find(params[:zone])
        zone.records
      end

      desc 'Create a Record.'
      params do
        requires :name, type: String, desc: 'Record name.'
        requires :record_type, type: String, desc: 'Record type (A or CNAME).', values: %w(A CNAME)
        requires :record_data, type: String, desc: 'Record data.'
        optional :ttl, type: Integer, desc: 'Time To Live.', default: 3600
        requires :zone, type: Integer, desc: 'Zone ID.'
      end
      post do
        zone = Zone.find(params[:zone])
        Record.create!({
          name: params[:name],
          record_type: params[:record_type],
          record_data: params[:record_data],
          ttl: params[:ttl],
          zone: zone
        })
      end

      desc 'Update a Record.'
      params do
        requires :id, type: Integer, desc: 'Record ID.'
        optional :name, type: String, desc: 'Record name.'
        optional :record_type, type: String, desc: 'Record type (A or CNAME).', values: %w(A CNAME)
        optional :record_data, type: String, desc: 'Record data.'
        optional :ttl, type: Integer, desc: 'Time To Live.'
      end
      put ':id' do
        record = Record.find(params[:id])
        record.update!(permitted_params)
        record
      end

      desc 'Delete a Record.'
      params do
        requires :id, type: Integer, desc: 'Record ID.'
      end
      delete ':id' do
        Record.find(params[:id]).destroy
      end

    end

  end
end
