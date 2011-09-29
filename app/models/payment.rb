class Payment < ActiveRecord::Base

  belongs_to :payee, :class_name => "User"
  belongs_to :payor, :class_name => "User"
  
  validates_presence_of :payee_id, :payor_id, :date, :transaction_type
  validates_length_of :notes, :maximum  => 255, :too_long => "Please enter fewer than 255 characters for notes." 
  
  EXTERNAL_PAYMENT=1
  PAYPAL_PAYMENT=2
  TRANSACTION_TYPE_NAMES = { EXTERNAL_PAYMENT => "Other", PAYPAL_PAYMENT => "PayPal"}
  
  def validate()
    errors.add("transaction type", "is not valid") unless TRANSACTION_TYPE_NAMES.has_key?(self.transaction_type)
  end
  
  def editor?(user)
    return (user.id == self.payor_id or user.id == self.payee_id)
  end
  
  def direction
    return (self.payee_id == User.current_user.id) ? 'payee' : 'payor'
  end
  
  def other_user_id
    return (self.payee_id == User.current_user.id) ? self.payor_id : self.payee_id
  end
  
end
