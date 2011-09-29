class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column "name", :string, :null => false
      t.column "user_id", :integer, :null => false
      t.timestamps
    end
    
    create_table :debts_tags, :id => false do |t|
      t.column "tag_id", :integer, :null => false
      t.column "debt_id", :integer, :null => false
      t.timestamps
    end
    
  end

  def self.down
    drop_table :tags
  end
end
