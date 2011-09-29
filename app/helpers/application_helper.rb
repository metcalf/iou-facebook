# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def debt_link_list(debts, length)
    length = debts.length if length == nil
    
    debt_string = debts.first(length).map{ |d| link_to d.name, :controller => :debts, :action => :view, :id => d.id }.join(', ')
    if debts.length > length
      debt_string += '<br />'
      debt_string += link_to '(more)', :controller => :debts, :action => :results
    end
  end
  
  def tab_selected?(section)
    (section[:url_options][:controller] == params[:controller]) and
    (section[:url_options][:action] == params[:action])
  end
  
  def tab_items
    [
      { :name => "Home", :url_options => {:controller => 'users', :action => 'home'}},
      { :name => "IOUs", :url_options => {:controller => 'debts', :action => 'results'}},
      { :name => "Friends", :url_options => {:controller => 'users', :action => 'results'}},
      { :name => "Payments", :url_options => {:controller => 'payments', :action => 'results'}}
    ].collect do |section|
      fb_tab_item(section[:name], url_for(section[:url_options]), :selected => tab_selected?(section) )
    end.join("\n")
  end
  
  def link_to_friend(user_or_id, contents=nil)
    if(user_or_id.respond_to?(:fb_user))
      user_or_id = user_or_id.id
    end
    if contents == nil
      contents = '<fb:name uid="'+user_or_id.to_s+'" capitalize="true" linked="false"  />'
    end
    
    if user_or_id == @current_user.id
      return link_to(contents, :controller => :users, :action => :home)
    elsif @current_user.fb_user.friends_with?(user_or_id)
      return link_to(contents, :controller => :users, :action => :view, :id => user_or_id)
    else 
      return content_tag(:span, contents)
    end
  end

end
