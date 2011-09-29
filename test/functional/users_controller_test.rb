require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  def test_view_good
    post(:view, {:id => users(:metcalf).id},{ :test_user => users(:gabler).id})
    assert_response :success
    assert_equal users(:metcalf).id, assigns['person'].id
  end
  
  def test_view_not_allowed
    post(:view, {:id => users(:devloper).id},{ :test_user => users(:gabler).id})
    assert_redirected_to :action => :results
  end
  
  def test_view_not_found
    post(:view, {:id => 6},{ :test_user => users(:gabler).id})
    assert_redirected_to :action => :results
  end
  
  def test_home
    get(:home,{},{:test_user => users(:devloper).id})
    assert_response :success
  end
  
  def test_results
    post(:results, {},{ :test_user => users(:devloper).id})
    assert_response :success
    assert_equal 1, assigns['users'].length
    assert_equal users(:metcalf).id, assigns['users'].first.id
  end
  
  def test_results_page_two
    post(:results, {:page => 2},{ :test_user => users(:witch).id})
    assert_response :success
    assert_equal 1, assigns['users'].length
  end
  
end
