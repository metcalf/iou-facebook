class CreateDebtPayments < ActiveRecord::Migration
  def self.up
    create_table :debt_payments  do |t|
      t.column "amount", :decimal, :precision => 9, :scale => 2, :null => false
      t.column "payment_id", :integer, :null => false
      t.column "debt_id", :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :debt_payments
  end
end
