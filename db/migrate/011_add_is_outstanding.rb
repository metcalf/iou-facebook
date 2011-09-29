class AddIsOutstanding < ActiveRecord::Migration
  def self.up
    add_column "user_debts", "is_outstanding", :boolean, :default => true
  end
  
  def self.down
    remove_column "user_debts", "is_outstanding"
  end
end