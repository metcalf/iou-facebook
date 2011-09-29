class Image < ActiveRecord::Base
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :resize_to => '200x400',
                 :thumbnails => { :thumb => '100x100' },
                 :path_prefix => 'public/uploaded_images'

  validates_as_attachment

end