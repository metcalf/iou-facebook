class Debt < ActiveRecord::Base
  #has_and_belongs_to_many :tags, :uniq => true
  belongs_to :image
  
  has_many :user_debts, :dependent => :destroy
  has_many :users, :through => :user_debts
  
  belongs_to :creator, :class_name => 'User'
  
  validates_presence_of :creator_id, :image_id, :date
  validates_length_of :description, :within => 0..255,
                        :too_short => "Please enter a description longer than 3 characters",
                        :too_long => "Please enter a description shorter than 255 characters"
  validates_length_of :name, :within => 3..60,
                        :too_short => "Please enter a name longer than 3 characters",
                        :too_long => "Please enter a name shorter than 60 characters"            
  
  def before_destroy
    if self.image_id != 1
      self.image.destroy
    end
  end
  
  def current_user_debt
    if(user_debts.loaded?)
      user_debts.each do |user_debt|
        if user_debt.user_id == User.current_user.id
          return user_debt
        end
      end
    else
      UserDebt.find(:first, :conditions => {:user_id => User.current_user.id, :debt_id => self.id })
    end
  end
  
  def debits
    self.user_debts.select { |user_debt| user_debt.credit_amount < user_debt.debit_amount }
  end
  
  def credits
    self.user_debts.select { |user_debt| user_debt.credit_amount > user_debt.debit_amount }
  end
  
  def debtors
    self.debits.map { |user_debt| user_debt.user }
  end
  
  def creditors
    self.credits.map { |user_debt| user_debt.user }
  end
  
  
  def validate
    result = debits_equal_credits?
    if(not result)
      errors.add(:balance, "The amount owed by debtors must equal the amount creditors owe.")
    end
    return
  end
  
  def editor?(user)
    return (self.creator_id == user.id or (self.permissions_level == 2 and self.users.include?(user)))
  end
  
  def viewer?(user)
    return (self.creator_id == user.id or self.users.include?(user))
  end
  
  # Is the specified or current user a debtor for this debt?
  def debtor?(user=User.current_user)
    return self.amount(user) > 0
  end
  
  # The amount specified or current user owes(is owed)
  def amount(user=User.current_user,other_user=nil)
    if(other_user != nil)
      curr = self.amount(user)
      other = self.amount(other_user)
      # If both are the same sign, return zero
      if(curr * other > 0)
        return 0
      else
        amt = [curr.abs, other.abs].min
        return curr > 0 ? amt : -amt
      end
    else
      user_debt = UserDebt.find(:first, :conditions => {:user_id => user.id, :debt_id => self.id})
      if(user_debt != nil)
        return user_debt.amount
      else
        return 0
      end
    end
  end
  
  def debits_equal_credits?
    return 0.005 > UserDebt.sum('sum_creidt_amount_debit_amount', :conditions => {:debt_id => self.id}, :select => "(credit_amount - debit_amount)").to_f.abs
  end
  
end
