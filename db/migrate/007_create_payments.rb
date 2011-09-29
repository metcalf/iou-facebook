class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.column "payee_id", :integer, :null => false
      t.column "payor_id", :integer, :null => false
      t.column "transaction_type", :integer, :null => false
      t.column "date", :date, :null => false
      t.column "notes", :string, :default => ''
      t.timestamps
    end
    
  end

  def self.down
    drop_table :payments
  end
end
