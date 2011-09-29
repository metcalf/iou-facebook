class CreateDebts < ActiveRecord::Migration
  def self.up
    create_table :debts do |t|
      t.column "creator_id", :integer, :null => false
      t.column "date", :date, :null => false
      t.column "completed", :date, :null => true
      t.column "description", :text, :null => false
      t.column "name", :string, :null => false
      t.column "image_id", :integer, :default => 1 
      t.column "permissions_level", :integer, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :debts
  end
end
