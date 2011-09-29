require File.dirname(__FILE__) + '/../test_helper'

class UserDebtTest < ActiveSupport::TestCase
  fixtures :user_debts, :debts, :users

  def test_relationships
    assert_equal user_debts(:dinner_metcalf).user.id, users(:metcalf).id
    assert_equal user_debts(:dinner_metcalf).debt.id, debts(:dinner).id
    
    assert_equal user_debts(:dog_gabler).user.id, users(:gabler).id
    assert_equal user_debts(:dog_gabler).debt.id, debts(:dog).id   
  end
  
  def test_amount
    assert_in_delta -57.88, user_debts(:user_debts_070).amount, 0.005
  end
end
