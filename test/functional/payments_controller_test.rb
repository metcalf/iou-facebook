require File.dirname(__FILE__) + '/../test_helper'

class PaymentsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_results_basic
    get(:results,{},{:test_user => users(:devloper).id})
    assert_response :success
    
    assert_equal 1, assigns["payments"].length
    assert_equal payments(:dinner_payment).id, assigns["payments"].first.id
  end
  
  def test_results_filtered
    # TODO Filtered results
  end
  
  def test_add_start
    post(:edit,{:start => true, :other_user_id => users(:devloper).id },{:test_user => users(:metcalf).id})
    assert :success
    
    assert_equal users(:devloper).id, assigns['other_user_id']
  end
  
  def test_add_good
    form_values = { :other_user_id            => users(:devloper).id,
                    :direction          => 'payee',
                    :payment            => { 'date(1i)' => 2008,
                                            'date(2i)' => 12,
                                            'date(3i)' => 30 
                                           },
                    :amount             => 10.45,
                    :notes => 'These are some notes for my payment'
                   }
    post(:edit,form_values,{:test_user => users(:metcalf).id})
    assert_redirected_to :action => :results, :notice => "Payment was saved successfully."
    assert_equal 0, users(:devloper).amount
    assert_equal 20.25, users(:metcalf).amount
    assert_equal 2, users(:metcalf).receipts.length
    assert_equal 2, users(:devloper).payments.length
    assert (not user_debts(:dinner_metcalf).is_outstanding)
    assert (not user_debts(:dinner_devloper).is_outstanding)
  end
  
  def test_edit_good
    form_values = { :id                 => payments(:dinner_payment).id,
                    :other_user_id      => users(:metcalf).id,
                    :amount             => 10,
                    :direction          => 'payor',
                    :payment            => { 'date(1i)' => 2008,
                                            'date(2i)' => 12,
                                            'date(3i)' => 30 
                                           },
                    :notes => ''
                   }
    post(:edit,form_values,{:test_user => users(:devloper).id})
    assert_redirected_to :action => :results, :notice => "Payment was saved successfully."
    assert_equal 1, users(:metcalf).receipts.length
    assert_in_delta 20.45, users(:devloper).amount, 0.001
    assert_in_delta -0.2, users(:metcalf).amount, 0.001
    assert user_debts(:dinner_metcalf).is_outstanding
    assert user_debts(:dinner_devloper).is_outstanding
  end
  
  def test_edit_good_no_other_user
    form_values = { :id                 => payments(:dinner_payment).id,
                    :amount             => 10,
                    :direction          => 'payor',
                    :payment            => { 'date(1i)' => 2008,
                                            'date(2i)' => 12,
                                            'date(3i)' => 30 
                                           },
                    :notes => ''
                   }
    post(:edit,form_values,{:test_user => users(:devloper).id})
    
    assert_redirected_to :action => :results, :notice => "Payment was saved successfully."
    assert_equal 1, users(:metcalf).receipts.length
    assert_in_delta 20.45, users(:devloper).amount, 0.001
    assert_in_delta -0.2, users(:metcalf).amount, 0.001
  end
  
  def test_delete_good
    old_amount = users(:metcalf).amount
    
    form_values = { :id => payments(:dinner_payment).id }
    post(:delete, form_values,{:test_user => users(:metcalf).id})
    
    assert_redirected_to :action => :results, :notice => "Payment was deleted successfully"
    assert (not Payment.exists?(payments(:dinner_payment).id))
    assert_in_delta 20, old_amount - users(:metcalf).amount, 0.001
  end
  
  def test_delete_not_exist
    form_values = { :id => 10 }
    post(:delete, form_values,{:test_user => users(:metcalf).id})
    
    assert_redirected_to :action => :results, :warning => "Payment to be deleted does not exist"
  end
  
  def test_delete_not_allowed
    form_values = { :id => payments(:dinner_payment).id }
    post(:delete, form_values,{:test_user => users(:gabler).id})
    
    assert_redirected_to :action => :results, :warning => "You are not allowed to delete that payment"
  end
  
  def test_delete_no_id
    form_values = {}
    post(:delete, form_values,{:test_user => users(:gabler).id})
    
    assert_redirected_to :action => :results, :warning => "You must provide a payment to delete"
  end
  
  # TODO Test payments add/edit fail
  
end
