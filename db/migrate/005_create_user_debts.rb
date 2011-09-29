class CreateUserDebts < ActiveRecord::Migration
  def self.up
    create_table :user_debts do |t|
      t.column "user_id", :integer, :null => false
      t.column "debt_id", :integer, :null => false
      t.column "credit_amount", :float, :precision => 11, :scale => 2, :null => false
      t.column "debit_amount",  :float, :precision => 11, :scale => 2, :null => false
      t.column "is_outstanding", :boolean, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :user_debts
  end
end
