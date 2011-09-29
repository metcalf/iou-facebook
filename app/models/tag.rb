class Tag < ActiveRecord::Base
  has_and_belongs_to_many :debts
  belongs_to :user
  
  validates_length_of :name, :within => 2..40,
                       :too_long => "Tags must be shorter than 40 characters long",
                       :too_short => "Tags must be 3 characters or longer"
  validates_format_of :name, :with => /\A[a-zA-Z ]*\Z/,
                        :mesage => "Tags can only contain letters and spaces."
  validates_presence_of :user_id
  
  before_save :strip_name
  
  def editor?(user)
    return (user.id == self.user_id)
  end
  
  private
  
  def strip_name
    self.name = self.name.strip
  end

end
