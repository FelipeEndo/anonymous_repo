class AddTransactionHistoryTables < ActiveRecord::Migration[5.1]
  def change
    remove_column :ticket_types, :zone_id
    remove_column :transaction_histories, :opamount
    remove_column :transaction_histories, :discount_amount_123
  end
end
