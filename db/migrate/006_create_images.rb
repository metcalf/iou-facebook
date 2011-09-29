class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :parent_id,  :integer
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
    
    Image.create(:id => 1, :content_type => "image/jpeg", 
              :filename => "iou.jpg", :size => 1086, :width => 200, :height => 127)
    Image.create(:id => 2, :parent_id => 1, :content_type => "image/jpeg", :thumbnail => "thumb", 
              :filename => "iou_thumb.jpg", :size => 3007, :width => 100, :height => 100)
    
  end

  def self.down
    drop_table :images
  end
end
