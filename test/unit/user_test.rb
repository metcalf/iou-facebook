require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :user_debts, :debts, :users
  
  def test_payments_to
    assert_equal -20, users(:metcalf).payments_to()
    assert_equal -20, users(:metcalf).payments_to(users(:devloper))
    assert_equal 20, users(:devloper).payments_to(users(:metcalf))
    assert_equal 0, users(:metcalf).payments_to(users(:gabler))
  end
  
  def test_amount
    # Metcalf all
    assert_in_delta 9.8, users(:metcalf).amount, 0.005
    assert_in_delta -10.45, users(:metcalf).amount(users(:devloper)), 0.005
    assert_in_delta 20.25, users(:metcalf).amount(users(:gabler)), 0.005
    
    # Gabler, select
    assert_in_delta -20.25, users(:gabler).amount, 0.005
    assert_in_delta 0, users(:gabler).amount(users(:devloper)), 0.005
    
    # Ensure transitivity of nets
    assert_in_delta users(:gabler).amount(users(:metcalf)), -users(:metcalf).amount(users(:gabler)), 0.005
    assert_in_delta users(:gabler).amount(users(:devloper)), -users(:devloper).amount(users(:gabler)), 0.005
    assert_in_delta users(:metcalf).amount(users(:devloper)), -users(:devloper).amount(users(:metcalf)), 0.005
    
    # Correct multiple people
    assert_in_delta  41.94, users(:another).amount(users(:barr)), 0.005
    assert_in_delta  -41.94, users(:barr).amount(users(:another)), 0.005
    assert_in_delta  0, users(:another).amount(users(:victoria)), 0.005
    
  end
  
  def test_relationships
    assert_equal 1, users(:metcalf).own_debts.length
    assert_equal 0, users(:devloper).own_debts.length
    assert_equal 1, users(:gabler).own_debts.length
    
    assert_equal debts(:dinner).id, users(:metcalf).own_debts[0].id
    assert_equal debts(:dog).id, users(:gabler).own_debts[0].id
    
    assert_equal user_debts(:dinner_devloper), users(:devloper).user_debts.first
    assert_equal 2, users(:metcalf).user_debts.length
    
    #assert_equal 3, users(:witch).tags.length
    #assert_equal tags(:food), users(:metcalf).tags.first
  end
  
  def test_debtor?
    # All for metcalf
    assert (not users(:metcalf).debtor?(users(:devloper)))
    assert (users(:metcalf).debtor?(users(:gabler)))
    
    # Transitivity
    assert (not (users(:metcalf).debtor?(users(:devloper)) and (users(:devloper).debtor?(users(:metcalf)))))
    assert (not (users(:metcalf).debtor?(users(:gabler)) and (users(:gabler).debtor?(users(:metcalf)))))
    assert (not (users(:gabler).debtor?(users(:devloper)) and (users(:devloper).debtor?(users(:gabler)))))
    
  end
  
  def test_debts
    # Test all for metcalf
    assert_equal 2, users(:metcalf).debts.length
    assert users(:metcalf).debts.include?(debts(:dinner))
    assert users(:metcalf).debts.include?(debts(:dog))
    
    assert_equal 1, users(:metcalf).debts(users(:devloper)).length
    assert users(:metcalf).debts(users(:devloper)).include?(debts(:dinner))
    
    
    assert_equal 1, users(:metcalf).debts(users(:gabler)).length
    assert users(:metcalf).debts(users(:gabler)).include?(debts(:dog))
    
    # Test counts for devloper and gabler and transitivity
    assert_equal 1, users(:devloper).debts.length
    assert_equal 1, users(:gabler).debts.length
    
    # TODO improve transitivity test to ensure debt id's are actually equal
    assert_equal users(:gabler).debts(users(:devloper)).length, users(:devloper).debts(users(:gabler)).length
    assert_equal users(:metcalf).debts(users(:devloper)).length, users(:devloper).debts(users(:metcalf)).length
    assert_equal users(:gabler).debts(users(:metcalf)).length, users(:metcalf).debts(users(:gabler)).length
  end
  
  def test_friends
    assert users(:metcalf).friends.include?(users(:devloper))
    assert users(:metcalf).friends.include?(users(:gabler))
    assert users(:gabler).friends.include?(users(:metcalf))
    assert users(:devloper).friends.include?(users(:metcalf))
    assert (not users(:devloper).friends.include?(users(:gabler)))
    
  end
  
  def test_num_friends
    assert_equal 2, users(:metcalf).num_friends
    assert_equal 1, users(:devloper).num_friends
    assert_equal 1, users(:gabler).num_friends
  end
  
  def test_facebooker
    assert_not_nil users(:metcalf).fb_user
  end
  
end
