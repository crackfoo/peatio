class CreateWhitelistedSmartContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :whitelisted_smart_contracts do |t|
      t.string  :description,    default: ''
      t.string  :address,        default: '', null: false
      t.string  :state,          default: '', null: false, limit: 30
      t.string  :blockchain_key, default: '', null: false, limit: 32
      t.timestamps
    end
  end
end
