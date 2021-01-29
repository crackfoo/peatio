# frozen_string_literal: true

module API
  module V2
    module Admin
      class WhitelistedSmartContracts < Grape::API
        helpers ::API::V2::Admin::Helpers
        content_type :csv, 'text/csv'

        desc 'Get all whitelisted addresses, result is paginated.',
             is_array: true,
             success: API::V2::Admin::Entities::WhitelistedSmartContract
        params do
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelisted_address.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.WhitelistedSmartContract[:blockchain_key][:desc] }
          use :pagination
          use :ordering
        end
        get '/whitelisted_smart_contracts' do
          admin_authorize! :read, WhitelistedSmartContract

          ransack_params = Helpers::RansackBuilder.new(params).eq(:blockchain_key).build

          search = ::WhitelistedSmartContract.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          if params[:format] == 'csv'
            search.result
          else
            present paginate(search.result, false), with: API::V2::Admin::Entities::WhitelistedSmartContract
          end
        end

        desc 'Get a whitelisted address.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.whitelisted_smart_contract.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:id][:desc] }
        end
        get '/whitelisted_smart_contracts/:id' do
          admin_authorize! :read, WhitelistedSmartContract

          present ::WhitelistedSmartContract.find(params[:id]), with: API::V2::Admin::Entities::WhitelistedSmartContract
        end

        desc 'Creates new whitelisted address.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelisted_address.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:blockchain_key][:desc] }
          requires :address,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:address][:desc] }
          optional :description,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:description][:desc] }
          optional :state,
                   values: { value: %w[active disabled], message: 'admin.whitelisted_address.invalid_status' },
                   default: 'active',
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:state][:desc] }
        end
        post '/whitelisted_smart_contracts/new' do
          admin_authorize! :create, WhitelistedSmartContract

          whitelisted_address = ::WhitelistedSmartContract.new(declared(params))
          if whitelisted_address.save
            present whitelisted_address, with: API::V2::Admin::Entities::WhitelistedSmartContract
            status 201
          else
            body errors: whitelisted_address.errors.full_messages
            status 422
          end
        end

        desc 'Update whitelisted_smart_contract.' do
          success API::V2::Admin::Entities::WhitelistedSmartContract
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.whitelisted_address.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:id][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.whitelisted_address.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:blockchain_key][:desc] }
          optional :description,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:description][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:address][:desc] }
          optional :state,
                   values: { value: %w[active disabled], message: 'admin.whitelisted_address.invalid_status' },
                   desc: -> { API::V2::Admin::Entities::WhitelistedSmartContract.documentation[:state][:desc] }
        end
        post '/whitelisted_smart_contracts/update' do
          admin_authorize! :update, WhitelistedSmartContract
          whitelisted_address = ::WhitelistedSmartContract.find(params[:id])
          declared_params = declared(params, include_missing: false)

          if whitelisted_address.update(declared_params)
            present whitelisted_address, with: API::V2::Admin::Entities::WhitelistedSmartContract
          else
            body errors: whitelisted_address.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
