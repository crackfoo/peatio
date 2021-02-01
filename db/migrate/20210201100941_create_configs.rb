class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs do |t|
      # TODO: move here as much as possible configs
      t.string :platform_id, limit: 64
    end
  end
end
