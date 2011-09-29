require File.dirname(__FILE__) + '/../test_helper'

class DebtsControllerTest < ActionController::TestCase
  
  # Viewing 
  def test_view_success
    post(:view, {:id => 1}, {:test_user => users(:devloper).id})
    assert_response :success
    assert_equal 1, assigns['debt'].id
  end
  
  def test_view_not_found
    post(:view, {:id => 100}, {:test_user => users(:gabler).id})
    assert_response :redirect 
  end
  
  def test_view_restricted
    post(:view, {:id => 1}, {:test_user => users(:gabler).id})
    assert_response :redirect 
  end
  
  # Searching
  def test_results_all
    post(:results, {}, {:test_user => users(:metcalf).id})
    assert_response :success
    assert_equal 2, assigns['debts'].length
    #assert_equal '', assigns['tag']
    assert_equal assigns['own'], 0
  end
  
  def test_results_search
    post(:results, {:search => 'din'}, {:test_user => users(:metcalf).id})
    assert_response :success
    assert_equal assigns['own'], 0
    assert_equal 1, assigns['debts'].length
    assert_equal debts(:dinner).id, assigns['debts'].first.id
    
  end
  
  def test_results_own
    post(:results, {:own => '1'}, {:test_user => users(:metcalf).id})
    assert_response :success
    assert_equal 1, assigns['debts'].length
    assert_equal debts(:dinner).id, assigns['debts'].first.id
    #assert_equal '', assigns['tag']
    assert_equal assigns['own'], 1
  end
  
  # Tagging
#  def test_delete_tag_success
#    post(:delete_tag, {:tag_id => 1, :debt_id => 1}, {:test_user => users(:metcalf).id})
#    assert_response :success
#    assert_equal 1, debts(:dinner).tags.length
#  end
#  
#  def test_delete_tag_not_found
#    post(:delete_tag, {:tag_id => 100, :debt_id => 1}, {:test_user => users(:metcalf).id})
#    assert_response :error
#  end
#  
#  def test_delete_tag_restricted
#    post(:delete_tag, {:tag_id => 2, :debt_id => 1}, {:test_user => users(:metcalf).id})
#    assert_response :error
#  end
#  
#  def test_tag_comma_sep
#    post(:tag, {:debt_id => 2, :tags => "super   tag , anotherTag"}, {:test_user => users(:gabler).id})
#    assert_response :success
#    assert_equal 2, assigns['tags'].length
#    
#    tag_names = debts(:dog).tags.map{|tag| tag.name }
#    assert_equal 3, tag_names.length
#    assert tag_names.include?("super tag")
#    assert tag_names.include?("anothertag")
#  end
#  
#  def test_tag_array
#    post(:tag, {:debt_id => 2, :tags => ["super,? tag", "anot+-he4rT6ag"]}, {:test_user => users(:gabler).id})
#    assert_response :success
#    assert_equal 2, assigns['tags'].length
#    
#    tag_names = debts(:dog).tags.map{|tag| tag.name }
#    assert_equal 3, tag_names.length
#    assert tag_names.include?("super tag")
#    assert tag_names.include?("anothertag")
#  end
#  
#  def test_tag_exists_by_other_user
#    post(:tag, {:debt_id => 2, :tags => "personal"}, {:test_user => users(:metcalf).id})
#    assert_response :success
#    assert_equal 0, assigns['tags'].length
#    assert_equal 1, debts(:dog).tags.length
#  end
#  
#  def test_tag_exists_by_current_user
#    post(:tag, {:debt_id => 1, :tags => "food"}, {:test_user => users(:metcalf).id})
#    assert_response :success
#    assert_equal 0, assigns['tags'].length
#    assert_equal 2, debts(:dinner).tags.length
#  end
#  
#  def test_tag_debt_not_found
#    post(:tag, {:debt_id => 100, :tags => "horse"}, {:test_user => users(:metcalf).id})
#    assert_response :error
#    assert (not Tag.exists?(:name => 'horse'))
#  end
  
  # Deleting

  def test_delete_success
    post(:delete, {:id => 1}, {:test_user => users(:metcalf).id})
    assert_redirected_to :action => :results, :warning => nil
    assert (not Debt.exists?(1))
    assert_equal 0, UserDebt.find_all_by_debt_id(1).length
    assert_in_delta users(:devloper).amount, -20, 0.005
    assert_in_delta users(:metcalf).amount, 40.25, 0.005
  end
  
  def test_delete_not_found
    post(:delete, {:id => 100}, {:test_user => users(:gabler).id})
    assert_redirected_to :action => :results, :warning => "The debt you attempted to delete could not be found"
  end
  
  def test_delete_restricted
    post(:delete, {:id => 1}, {:test_user => users(:gabler).id})
    assert_redirected_to :action => :results, :warning => "You do not have permission to delete the specified debt"
  end
  
  # Edit
  def test_edit_start_success
    get(:edit, {:id => 2}, {:test_user => users(:gabler).id})
    assert_response :success
    assert_equal 2, assigns['id']
    assigns['form_values'][:date] = 'hi'
    assert_equal assigns['form_values'], {
                                          :name => 'Dog',
                                          #:tags => debts(:dog).tags,
                                          :date => 'hi',#Date.parse('2008-01-20'),
                                          :debt_id => 2,
                                          :permissions_level => 2,
                                          :description => 'I paid for your dog.  Pay me back.',
                                          :creditor_selector_data => [{:selection_id => 1253603666, :amount => 20.25}],
                                          :debtor_selector_data => [{:selection_id => 616421, :amount => 20.25}]                             
                                          }
    
    
  end
  
  def test_edit_start_not_found
    get(:edit, {:id => 100}, {:test_user => users(:gabler).id})
    assert_redirected_to :action => :results, :warning => "The debt you attempted to edit could not be found"
  end
  
  def test_edit_start_restricted
    get(:edit, {:id => 1}, {:test_user => users(:gabler).id})
    assert_redirected_to :action => :results, :warning => "You do not have permission to edit the specified debt"
  end
  
  def test_edit_start_allowed_permission_two
    get(:edit, {:id => 2}, {:test_user => users(:metcalf).id})
    assert_response :success
    assert_equal 2, assigns['id']
  end
  
  def test_add_good_no_upload
    form_values = { :name         => "New Debt",
                    #:tags         => "personal, new tag",
                    :description  => "This is a debt made by a test \n really, a test",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 8,
                                       'date(3i)' => 27 
                                      },
                    :image => { :uploaded_data => ''},
                    :creditor_selector_data => {0 =>{:selection_id => 616421, :amount => 40}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}}
                  }
    post(:edit, form_values,{:test_user => users(:gabler).id})
    assert :redirect
    assert Debt.exists?(:name => "New Debt")
    newDebt = Debt.find(:first, :conditions =>{:name => "New Debt"})

    #assert_equal 2, newDebt.tags.length
    assert_equal form_values[:description], newDebt.description
    assert_equal Date.civil(2008, 8, 27).to_formatted_s, Date.parse(newDebt.date.to_formatted_s).to_formatted_s
    assert_equal 1, newDebt.image.id
    assert_equal -20, newDebt.amount(users(:metcalf))
    assert_equal 20, newDebt.amount(users(:gabler))
  end
  
  def test_add_empty
    form_values = { :name         => "",
                    #:tags         => "",
                    :description  => "t",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 8,
                                       'date(3i)' => 27 
                                      },
                    :image => { :uploaded_data => ''},
                  }
    post(:edit, form_values,{:test_user => users(:gabler).id})
    assert_redirected_to :action => :edit
    assert @response.redirect_url.include?("form_values")
    assert (not Debt.exists?(:name => ""))
  end
  
  def test_edit_empty
    form_values = { :id           => 2,
                    :name         => "",
                    #:tags         => "",
                    :description  => "t",
                    :debt         => { 'date(1i)' => '',
                                       'date(2i)' => '',
                                       'date(3i)' => '' 
                                      },
                    :image => { :uploaded_data => ''},
                    :permissions_level => ''
                  }
    post(:edit, form_values,{:test_user => users(:gabler).id})
    assert_redirected_to :action => :edit
    assert Debt.find(2).name != ""
    assert @response.redirect_url.include?("form_values")
  end
  
  def test_edit_restart
    form_values = {
                    :date => '2008-08-23',
                    :description => '',
                    :name => '',
                    #:tags => '',
                    :permissions_level => ''
                  }
    get(:edit,{:form_values => form_values},{:test_user => users(:metcalf).id})
    assert :success
  end
  
  def test_edit_restart_content
    form_values = {
                    :date => '2008-08-23',
                    :description => 'dsfsdpoppoi',
                    :name => 'dododso',
                    #:tags => 't',
                    :permissions_level => '2'
                  }
    get(:edit,{:form_values => form_values},{:test_user => users(:metcalf).id})
    assert :success
  end
  
  def test_edit_restart_tag
    form_values = {
                    :date => '2008-08-23',
                    :description => 'dsfsdpoppoi',
                    :name => 'dododso',
                    #:tags => '',
                    :permissions_level => '',
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}}
                  }
    get(:edit,{:form_values => form_values},{:test_user => users(:metcalf).id})
    assert :success
  end
  
  def test_add_good_upload
    form_values = { :name         => "Another New",
                    #:tags         => ["oh tags", "tag me baby"],
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :image => { :uploaded_data => uploaded_jpeg(RAILS_ROOT+'/test/Photo5.jpg')},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}},
                    :permissions_level => '2',
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert :redirect
    assert Debt.exists?(:name => "Another New")
    newDebt = Debt.find(:first, :conditions =>{:name => "Another New"})

    #assert_equal 2, newDebt.tags.length
    assert newDebt.editor?(users(:metcalf))
    assert newDebt.editor?(users(:gabler))
    assert (not newDebt.editor?(users(:devloper)))
    assert_equal "Photo5.jpg", newDebt.image.filename
    assert_equal form_values[:description], newDebt.description
    assert_equal Date.civil(2008, 12, 30).to_formatted_s, Date.parse(newDebt.date.to_formatted_s).to_formatted_s
    assert_equal -20, newDebt.amount(users(:metcalf))
    assert_equal 20, newDebt.amount(users(:gabler))
    
  end
  
  def test_edit_good_same_users
    form_values = { :id           => 1,
                    :name         => "Another New",
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :image => { :uploaded_data => ''},
                    :permissions_level => '1',
                    :creditor_selector_data => {0 =>{:selection_id => 1261073945, :amount => 5}, 1 => {:selection_id => 616421, :amount => 35}},
                    :debtor_selector_data => {1=> {:selection_id => 1261073945, :amount => 40}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert :redirect
    assert Debt.exists?(:name => "Another New")
    newDebt = Debt.find(:first, :conditions =>{:name => "Another New"})

    #assert_equal 2, newDebt.tags.length
    assert newDebt.editor?(users(:metcalf))
    assert (not newDebt.editor?(users(:gabler)))
    assert (not newDebt.editor?(users(:devloper)))
    assert_equal 1, newDebt.image.id
    assert_equal form_values[:description], newDebt.description
    assert_equal Date.civil(2008, 12, 30).to_formatted_s, Date.parse(newDebt.date.to_formatted_s).to_formatted_s
    assert_in_delta -35, newDebt.amount(users(:metcalf)), 0.005
    assert_in_delta 35, newDebt.amount(users(:devloper)), 0.005
    
    assert_in_delta 5.25, users(:metcalf).amount, 0.005
    assert_in_delta -20.25, users(:gabler).amount, 0.005
    assert_in_delta 15, users(:devloper).amount, 0.005
  end
  
  def test_edit_good_new_users_permission_two
    form_values = { :id           => 2,
                    :name         => "Another New",
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :permissions_level => 2,
                    :image => { :uploaded_data => uploaded_jpeg(RAILS_ROOT+'/test/Photo5.jpg')},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}, 1=> {:selection_id => 1261073945, :deleted => true}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert :redirect
    assert Debt.exists?(:name => "Another New")
    newDebt = Debt.find(:first, :conditions =>{:name => "Another New"})

    #assert_equal 1, newDebt.tags.length

    assert_equal "Photo5.jpg", newDebt.image.filename
    assert_equal form_values[:description], newDebt.description
    assert_equal Date.civil(2008, 12, 30).to_formatted_s, Date.parse(newDebt.date.to_formatted_s).to_formatted_s
    assert_in_delta -20, newDebt.amount(users(:metcalf)), 0.005
    assert_in_delta 20, newDebt.amount(users(:gabler)), 0.005
    
    assert_in_delta -30.45, users(:metcalf).amount, 0.005
    assert_in_delta 20, users(:gabler).amount, 0.005
    assert_in_delta 10.45, users(:devloper).amount, 0.005
  end
  
  def test_edit_restricted
    form_values = { :id           => 1,
                    :name         => "Another New",
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :permissions_level => '1',
                    :image => { :uploaded_data => uploaded_jpeg(RAILS_ROOT+'/test/Photo5.jpg')},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}, 1=> {:selection_id => 1261073945, :deleted => true}}
                  }
    post(:edit, form_values,{:test_user => users(:devloper).id})
    assert :redirect
    assert (not Debt.exists?(:name => "Another New"))
  end
  
  def test_edit_unequal_amount
    form_values = { :id           => 1,
                    :name         => "Another New",
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :permissions_level => '1',
                    :image => { :uploaded_data => uploaded_jpeg(RAILS_ROOT+'/test/Photo5.jpg')},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 30}, 1 => {:selection_id => 616421, :amount => 20}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}, 1=> {:selection_id => 1261073945, :deleted => true}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert_redirected_to :action => :edit
    assert Debt.exists?(1)
    assert_equal "Dinner", debts(:dinner).name
    assert_equal -30.45, debts(:dinner).amount(users(:metcalf))
    assert_equal 30.45, debts(:dinner).amount(users(:devloper))
  end
  
  def test_add_unequal_amount
    form_values = { :name         => "Another New",
                    :description  => "Not another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :permissions_level => '1',
                    :image => { :uploaded_data => ''},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 30}, 1 => {:selection_id => 616421, :amount => 20}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}, 1=> {:selection_id => 1261073945, :deleted => true}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert_redirected_to :action => :edit
    assert (not Debt.exists?(:name => "Another New"))
    assert_equal -30.45, debts(:dinner).amount(users(:metcalf))
    assert_equal 30.45, debts(:dinner).amount(users(:devloper))
  end
  
  def test_edit_name_short_desc_long
    form_values = { :id           => 1,
                    :name         => "Ab",
                    :description  => "Not another one.... grrr testingNot another one.... grrr testingNot another one.... grrr testingNot another one.... grrr testingNot another one.... grrr testingNot another one.... grrr testingNot another one.... grrr testing",
                    :debt         => { 'date(1i)' => 2008,
                                       'date(2i)' => 12,
                                       'date(3i)' => 30 
                                      },
                    :permissions_level => '1',
                    :image => { :uploaded_data => uploaded_jpeg(RAILS_ROOT+'/test/Photo5.jpg')},
                    :creditor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 20}, 1 => {:selection_id => 616421, :amount => 20}},
                    :debtor_selector_data => {0 =>{:selection_id => 1253603666, :amount => 40}, 1=> {:selection_id => 1261073945, :deleted => true}}
                  }
    post(:edit, form_values,{:test_user => users(:metcalf).id})
    assert_redirected_to :action => :edit
  end

private

  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  
  # a JPEG helper
  def uploaded_jpeg(path, filename=nil)
    uploaded_file(path, 'image/jpeg', filename)
  end

end
