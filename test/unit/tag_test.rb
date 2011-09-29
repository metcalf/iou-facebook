require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_relationships
    assert_equal tags(:personal_gabler).user, users(:gabler)
    assert_equal tags(:personal_devloper).user, users(:devloper)
    
    assert_equal 1, tags(:personal_gabler).debts.length
    assert_equal debts(:dog), tags(:personal_gabler).debts.first
    
    assert_equal 2, tags(:tags_003).debts.length
  end
  
  def test_editor_access
    assert tags(:personal_gabler).editor?(users(:gabler))
    assert (not tags(:personal_devloper).editor?(users(:gabler)))
  end
  
  def test_validations
    tags(:personal_gabler).name = "b"
    assert (not tags(:personal_gabler).save)
    tags(:personal_gabler).name = "test"*11
    assert (not tags(:personal_gabler).save)
    tags(:personal_gabler).name = "good,./?"
    assert (not tags(:personal_gabler).save)
    tags(:personal_gabler).name = "good tag"
    
    tags(:personal_gabler).user_id = nil
    assert (not tags(:personal_gabler).save)
    tags(:personal_gabler).user_id = users(:gabler).id

    assert tags(:personal_gabler).save
  end
end
