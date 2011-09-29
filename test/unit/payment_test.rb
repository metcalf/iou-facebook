require File.dirname(__FILE__) + '/../test_helper'

class PaymentTest < ActiveSupport::TestCase
  def test_relationships
    assert_equal payments(:dinner_payment).payor, users(:devloper)
    assert_equal payments(:dinner_payment).payee, users(:metcalf)
  end
  
  def test_validation
    payments(:dinner_payment).payor_id = nil
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).payor_id = users(:devloper).id
    
    payments(:dinner_payment).payee_id = nil
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).payee_id = users(:metcalf).id
    
    payments(:dinner_payment).notes = ("test "*52)
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).notes = ""
    assert payments(:dinner_payment).save
    payments(:dinner_payment).notes = "test note"
    
    payments(:dinner_payment).date = nil
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).date = Time.now()
    
    payments(:dinner_payment).transaction_type = nil
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).transaction_type = 10
    assert (not payments(:dinner_payment).save)
    payments(:dinner_payment).transaction_type = 1
    
    assert payments(:dinner_payment).save
  end
  
  def test_editor_access
    assert payments(:dinner_payment).editor?(users(:devloper))
    assert payments(:dinner_payment).editor?(users(:metcalf))
    assert (not payments(:dinner_payment).editor?(users(:gabler)))
  end
  
end
