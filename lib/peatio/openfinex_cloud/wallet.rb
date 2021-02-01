module OpenfinexCloud
  class Wallet < Peatio::Wallet::Abstract
    DEFAULT_FEATURES = { skip_deposit_collection: false }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :address, :secret)

      @currency = @settings.fetch(:currency) do
        raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(_options = {})
      response = client.rest_api(:post, '/address/new', {
                                   currency_id: currency
                                 })

      { address: response['address'], secret: response['passphrase'], details: response.except('address', 'passphrase') }
    rescue OpenfinexCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def create_transaction!(transaction)
      client.rest_api(:post, '/tx/send', {
                        currency_id: currency,
                        to: transaction.to_address,
                        amount: amount.to_i,
                        passphrase: wallet_secret
                      })

      transaction
    rescue OpenfinexCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def load_balance!
      response = client.rest_api(:post, '/address/balance', {
        currency_id: currency,
      }.compact).fetch('balance')

      response = response.yield_self { |amount| convert_from_base_unit(amount) } if coin_type == 'eth'

      response.to_d
    rescue OpenfinexCloud::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def wallet_address
      @wallet.fetch(:address)
    end

    def currency_id
      @currency.fetch(:id)
    end

    def client
      @client ||= Client.new(@wallet.fetch(:uri), idle_timeout: 1)
    end
  end
end
