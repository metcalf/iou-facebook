require File.dirname(__FILE__) + '/../test_helper'

class DebtTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :debts, :users, :user_debts
  
  # Test for validation of balance
  def test_validate_balance
    user_debts(:dog_metcalf).update_attribute('credit_amount',10)
    assert (not debts(:dog).debits_equal_credits?)
    user_debts(:dog_gabler).update_attribute('debit_amount', 10)
    assert debts(:dog).debits_equal_credits?
  end
  
  # Test for presence of image_id, creator_id, date
  def test_validate_presence
    debts(:dinner).image_id = nil
    assert (not debts(:dinner).save)
    debts(:dinner).image_id = 1
    
    debts(:dinner).creator_id = nil
    assert (not debts(:dinner).save)
    debts(:dinner).creator_id = 1
    
    debts(:dinner).date = nil
    assert (not debts(:dinner).save)
    debts(:dinner).date = Date.new
    
    assert debts(:dinner).save
  end
  
  # Test for description length < 255 and name length < 60
  def test_validate_length
    debts(:dog).description = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum"
    assert (not debts(:dog).save)
    debts(:dog).description = "That's better"
    
    debts(:dog).name = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor in"
    assert (not debts(:dog).save)
    debts(:dog).name = "That's much better"
    
    assert debts(:dog).save
  end
  
  
  def test_relationships
    # has_many user_debts
    assert_equal 2, debts(:dinner).user_debts.length
    assert debts(:dinner).user_debts.include?(user_debts(:dinner_devloper))
    assert debts(:dinner).user_debts.include?(user_debts(:dinner_metcalf))
    
    assert_equal 2, debts(:dog).user_debts.length
    assert debts(:dog).user_debts.include?(user_debts(:dog_metcalf))
    assert debts(:dog).user_debts.include?(user_debts(:dog_gabler))
    
    # has_many debits/credits
    assert_equal 1, debts(:dinner).debits.length
    assert_equal 1, debts(:dinner).credits.length
    assert debts(:dinner).debits.include?(user_debts(:dinner_devloper))
    assert debts(:dinner).credits.include?(user_debts(:dinner_metcalf))

    assert_equal 1, debts(:dog).debits.length
    assert_equal 1, debts(:dog).credits.length
    assert debts(:dog).debits.include?(user_debts(:dog_metcalf))
    assert debts(:dog).credits.include?(user_debts(:dog_gabler))
    
    # has_many creditors/debtors
    assert_equal 1, debts(:dinner).debtors.length
    assert_equal 1, debts(:dinner).creditors.length
    assert debts(:dinner).debtors.include?(users(:devloper))
    assert debts(:dinner).creditors.include?(users(:metcalf))

    assert_equal 1, debts(:dog).debtors.length
    assert_equal 1, debts(:dog).creditors.length
    assert debts(:dog).debtors.include?(users(:metcalf))
    assert debts(:dog).creditors.include?(users(:gabler))
    
    # belongs to creator
    assert_equal debts(:dinner).creator.id, users(:metcalf).id
    assert_equal debts(:dog).creator.id, users(:gabler).id
  end
  
  def test_debtor?
    assert (not debts(:dinner).debtor?(users(:metcalf)))
    assert debts(:dinner).debtor?(users(:devloper))
    assert (not debts(:dog).debtor?(users(:gabler)))
    assert debts(:dog).debtor?(users(:metcalf))
  end
  
  def test_users
    assert_equal 2, debts(:dinner).users.length
    assert debts(:dinner).users.include?(users(:metcalf))
    assert debts(:dinner).users.include?(users(:devloper))
    
    assert_equal 2, debts(:dog).users.length
    assert debts(:dog).users.include?(users(:metcalf))
    assert debts(:dog).users.include?(users(:gabler))
  end
  
  def test_amount_single
    assert_equal 30.45, debts(:dinner).amount(users(:devloper))
    assert_equal -30.45, debts(:dinner).amount(users(:metcalf))
    assert_equal 20.25, debts(:dog).amount(users(:metcalf))
    assert_equal -20.25, debts(:dog).amount(users(:gabler))
  end
  
  def test_amount_double
    assert_in_delta 0, debts(:old_stuff).amount(users(:witch), users(:barr)), 0.005
    assert_in_delta 0, debts(:old_stuff).amount(users(:barr), users(:witch)), 0.005
    
    assert_in_delta 0, debts(:may_pgw).amount(users(:victoria), users(:barr)), 0.005
    assert_in_delta 0, debts(:may_pgw).amount(users(:barr), users(:victoria)), 0.005
    
    assert_in_delta -11.61, debts(:june_comcast).amount(users(:witch), users(:barr)), 0.005
    assert_in_delta  11.61, debts(:june_comcast).amount(users(:barr), users(:witch)), 0.005
    assert_in_delta  0, debts(:june_comcast).amount(users(:barr), users(:victoria)), 0.005
    assert_in_delta  0, debts(:june_comcast).amount(users(:barr), users(:another)), 0.005
  end
  
  def test_editor?
    assert debts(:dog).editor?(users(:gabler))
    assert debts(:dog).editor?(users(:metcalf))
    debts(:dog).update_attribute('permissions_level', 1)
    assert (not debts(:dog).editor?(users(:metcalf)))
    assert debts(:dinner).editor?(users(:metcalf))
    assert (not debts(:dinner).editor?(users(:devloper)))
  end
  
end
