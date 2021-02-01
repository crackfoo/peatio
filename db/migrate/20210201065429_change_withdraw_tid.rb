class ChangeWithdrawTID < ActiveRecord::Migration[5.2]
  def change
    change_column :withdraws, :tid, :string, limit: 64, null: true
  end
end
