class UserDebt < ActiveRecord::Base
  belongs_to :debt
  belongs_to :user
  
  validates_presence_of :user_id, :debt_id
  
  def amount
    self.debit_amount - self.credit_amount
  end
  
end
