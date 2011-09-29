class User < ActiveRecord::Base
  cattr_accessor :current_user
  has_many :own_debts, :class_name => 'Debt', :foreign_key => 'creator_id'
  has_many :user_debts
  #has_many :tags
  
  has_many :payments, :class_name => 'Payment', :foreign_key => 'payor_id'
  has_many :receipts, :class_name => 'Payment', :foreign_key => 'payee_id'
  
  attr_reader :fb_user
  attr_accessor :friend_find
  
  def after_initialize
    @fb_user = Facebooker::User.new(self.id)
    @friend_find = { :include => :user_debts, :conditions => 
                  ["users.id != ? AND user_debts.debt_id IN (SELECT debt_id FROM user_debts WHERE `user_debts`.user_id = ?)", self.id, self.id] }
  end
  
  # Amount this user owes(is owed) the specified user or all users
  def amount(user=nil)
    result = 0
    self.debts(user).each do |debt|
      result += debt.amount(self, user)
    end
    result -= payments_to(user)
    
    return result
  end
  
  # Amount this user has paid the specified user
  def payments_to(user=nil)
    payorConditions = user != nil ? ['payor_id = ? AND payee_id = ?', self.id, user.id] : ['payor_id = ?',self.id]
    payeeConditions = user != nil ? ['payee_id = ? AND payor_id = ?', self.id, user.id] : ['payee_id = ?',self.id]
    
    payor = Payment.sum(:amount, :conditions => payorConditions)
    payor ||= 0
    payee = Payment.sum(:amount, :conditions => payeeConditions)
    payee ||= 0
    payor - payee
  end
  
  # Is this user a debtor to the current user or specified user?
  def debtor?(user=User.current_user)
    return self.amount(user) > 0
  end

  # No user parameter: all debts this user is associated with
  # User parameter: all debts this user owes the specified user
  def debts(user=nil)
    if(user.nil?)
      return Debt.find(:all, :include => :user_debts, :conditions => ["user_debts.user_id = ?", self.id])
    else
      return Debt.find(:all, :include => :user_debts, :conditions => 
                        ["user_debts.user_id = ? AND user_debts.debt_id IN (SELECT debt_id FROM user_debts WHERE `user_debts`.user_id = ?)", self.id, user.id])
    end
  end
  
  def friends
    return User.find(:all, self.friend_find)
  end
  
  # Number of friends this user has debts with
  def num_friends
    return self.friends.length
  end  
  
  def before_destroy
    throw "Users should never be destroyed"
  end
  
  def self.update_outstandings(user_id, other_user_ids)
    amounts = {}
    other_user_ids.each { |other_user_id| amounts[other_user_id] = 0 }
    
    iou_amts = UserDebt.find(:all, :conditions => {:user_id => user_id}, :select => "`amount`")
    payments = Payment.sum(:amount, :conditions => ['payor_id = ? AND payee_id IN ?', user_id, other_user_ids], :group => "`payee_id`")
    receipts = Payment.sum(:amount, :conditions => ['payee_id = ? AND payor_id IN ?', user_id, other_user_ids], :group => "`payor_id`")
    payor ||= 0
    payee ||= 0
    payments.each_pair { |other_user_id, amount| amounts[other_user_id] - amount.to_f }
    receipts.each_pair { |other_user_id, amount| amounts[other_user_id] + amount.to_f }
  end
  
end