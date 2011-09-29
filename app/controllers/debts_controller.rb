class DebtsController < ApplicationController
  
  ALLOWED_PARAMS = ['name', 'id', 'tags', 'date', 'debt_id', 'creditor_selector_data', 'debtor_selector_data', 'description', 'permissions_level']
  
  def edit
    if(params.has_key?(:id) and not request.post?)
      begin 
        debt = Debt.find(params[:id])
        if(debt.editor?(@current_user))
          @form_values = form_from_debt(debt)
          @id = debt.id
        else
          redirect_to :action => :results, :warning => "You do not have permission to edit the specified debt"
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => :results, :warning => "The debt you attempted to edit could not be found"
      end
    elsif request.post?
      begin 
        params[:date] = Date.civil(params[:debt]['date(1i)'].to_i,params[:debt]['date(2i)'].to_i,params[:debt]['date(3i)'].to_i)
        result = edit_add_debt(params)
        flash[:notice] << "'"+result.name+"' was saved successfully."
        redirect_to :action => :view, :id => result.id, :notice => flash[:notice]
      rescue StandardError => error
        logger.info error.to_s + error.backtrace.join('\n');
        redirect_to :action => :edit, :form_values => params.reject {|key, val| not ALLOWED_PARAMS.include?(key) }, :warning => flash[:warning]
      end
    else
      if(params.has_key?(:form_values))
        @form_values = params[:form_values]
      end
    end
  end
  
  def delete
    begin
      debt = Debt.find(params[:id])
      if (not debt.editor?(@current_user))
        redirect_to :action => :results, :warning => "You do not have permission to delete the specified debt"
      else
        flash[:notice] << "You successfully deleted the debt '"+debt.name+"'"
        debt.destroy
        redirect_to :action => :results
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => :results, :warning => "The debt you attempted to delete could not be found"
    end
  end

  def results
    
    finder = {:page => params[:page], 
            :per_page => 10, 
            :include => [:user_debts], 
            :order => 'date DESC',
            :conditions => ['debts.id IN (SELECT debt_id FROM user_debts WHERE user_id = ?)', @current_user.id]}

    #if(params.has_key?(:tag) and not params[:tag].empty?)
    #  finder[:include] << :tags
    #  finder[:conditions][0] = "tags.name = ? AND " + finder[:conditions][0]
    #  finder[:conditions].insert(1, params[:tag])
    #  @tag = params[:tag]
    #else
    #  @tag = ''
    #end
    #@tag ||= ''
    #@tags = Tag.find(:all, :group => 'tags.name', :include => :debts, :conditions => ["debts.id IN (SELECT debt_id FROM user_debts WHERE user_debts.user_id = ?)", @current_user.id])
    
    if(params.has_key?(:own))
      finder[:conditions][0] = "debts.creator_id = ? AND " + finder[:conditions][0]
      finder[:conditions].insert(1, @current_user.id)
      @own = 1
    else
      @own = 0
    end
    
    if(params.has_key?(:search) and not params[:search].empty?)
      finder[:conditions][0] = "debts.description LIKE ? OR debts.name LIKE ? AND " + finder[:conditions][0]
      finder[:conditions].insert(1, '%'+params[:search]+'%')
      finder[:conditions].insert(1, '%'+params[:search]+'%')
      @search = params[:search]
    else
      @search = ""
    end
    
    @debts = Debt.paginate(finder)
    @sum_debts = @debts.inject(0){ |sum, elem| sum + elem.amount }
  end
  
  def delete_tag
    tag_id = params[:tag_id]
    debt_id = params[:debt_id]
    begin
    tag = Tag.find(tag_id)
      if(tag.editor?(@current_user))
        debt = Debt.find(debt_id)
        tag.debts.delete(debt) unless debt == nil
        render :text => "success"
      else
        render :text => "You do not have permission to delete that tag.", :status => 500
      end
    rescue ActiveRecord::RecordNotFound
      render :text => "The tag you attempted to delete could not be found", :status => 500
    end
    
  end
  
  def tag(debt_id=nil, tag_names=nil)
    called = (debt_id != nil)
    debt_id ||= params[:debt_id]
    tag_names ||= params[:tags]
    
    if(tag_names.kind_of?(String))
      tag_names = tag_names.split(/\s*,\s*/)
    end
    
    begin
      @tag_debt = Debt.find(debt_id)
    rescue ActiveRecord::RecordNotFound
      if(called)
        flash[:warning] << "That debt doesn't exist! Invalid request"
        return false
      else
        render :text => "That debt doesn't exist! Invalid request", :status => 500
        return
      end
    end
    
    @tags = []
    debt_tag_names = @tag_debt.tags.map{|tag| tag.name }
    tag_names.each do |tag_name|
      tag_name = tag_name.gsub(/[^a-zA-Z\ ]*/,'').gsub(/\ {2,}/,' ').strip
      if(not debt_tag_names.include?(tag_name))
        @tags.push(Tag.find_or_create_by_name_and_user_id(tag_name.downcase, @current_user.id))
      end
    end
    
    @tag_debt.tags<<@tags
    
    if(called)
      return true
    else
      flash[:notice] << "The tags '" + tag_names.join(", ") + "' were added to '" + @tag_debt.name
      render :layout => false
    end
  end
  
  def view
    begin
      @debt = Debt.find(params[:id], :include => [ :user_debts ]) # Also included tags
      if(not @debt.viewer?(@current_user))
        redirect_to :action => :results, :warning => "Sorry, you do not have permission to view that debt"
      else
        return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => :results, :warning => "Sorry, that debt could not be found"
    end
  end
  
  private
  
  def path_prefix
    "apps.facebook.com/iou-facebook"
  end
  
  def edit_add_debt(params)
    attribs = {:date => params[:date], :description => params[:description].to_s, :name => params[:name].to_s, :permissions_level => params[:permissions_level].to_i}
    debt = nil
    Debt.transaction do
      if(params.has_key?(:id))
        debt = Debt.find(params[:id])
        if(debt == nil)
          flash[:warning] << "The specified debt does not exist"
          raise "0"
        elsif(debt.editor?(@current_user))
          if(not debt.update_attributes(attribs))
            flash[:warning] += debt.errors.full_messages
            raise "0"
          end
        else
          flash[:warning] << "You are not permitted to edit this debt"
          raise "0"
        end
      else
        attribs[:creator_id] = @current_user.id
        debt = Debt.new(attribs)
        if(not debt.save)
          flash[:warning] += debt.errors.full_messages
          raise "0"
        end
      end
      
      if(not set_user_debts(params[:creditor_selector_data], params[:debtor_selector_data], debt))
        if(params.has_key?(:id))
          raise "0"
        else
          raise debt.id.to_s
        end
      end
      
#      if(params.has_key?(:tags))
#        if(not self.tag(debt.id, params[:tags]))
#          if(params.has_key?(:id))
#            raise "0"
#          else
#            raise debt.id.to_s
#          end
#        end
#      end
      
      if(params[:image][:uploaded_data].respond_to?(:original_filename))
        image_data = {:uploaded_data => params[:image][:uploaded_data]}
        image = Image.new(image_data)
        if image.save
          debt.image = image
        else
          flash[:warning] += image.errors.full_messages
        end
      end
      
      if(not debt.save)
        flash[:warning] += debt.errors.full_messages
        if(params.has_key?(:id))
          raise "0"
        else
          raise debt.id.to_s
        end
      end
    end # End transaction
    
    return debt
  end
  
  def set_user_debts(creditors, debtors, debt)
    
    creditors.each_value do |data|
      user_ids << data[:selection_id]
      user_data[data[:selection_id]] ||= {}
      if(data.has_key?(:deleted))
        user_data[data[:selection_id]][:credit_amount] = 0
      else
        user_data[data[:selection_id]][:credit_amount] = data[:amount].to_f
      end
      user_data[data[:selection_id]][:debit_amount] ||= 0
    end
    
    debtors.each_value do |data|
      
      user_data[data[:selection_id]] ||= {}
      user_data[data[:selection_id]][:credit_amount] ||= 0
      if(data.has_key?(:deleted))
        user_data[data[:selection_id]][:debit_amount] = 0
      else
        user_data[data[:selection_id]][:debit_amount] = data[:amount].to_f
      end
    end
    
    user_data.each_pair do |user_id, data|
      user = User.find_or_create_by_id(user_id)
      user_debt = UserDebt.find(:first, :conditions => {:user_id => user.id, :debt_id => debt.id})
      if(user_debt == nil)
        user_debt = UserDebt.new(:user_id => user.id, :debt_id => debt.id)
      elsif(data[:debit_amount] == 0 and data[:credit_amount] == 0)
        user_debt.destroy
        next
      end
      
      if( not user_debt.update_attributes(:credit_amount => data[:credit_amount], :debit_amount => data[:debit_amount]))   
        flash[:warning] += user_debt.errors.full_messages
        return false
      end
      
    end
    
    user_ids = user_data.keys
    user_ids.each { |user_id| User.update_outstanding(user_id, user_ids) }
    
    if(debt.debits_equal_credits?)
      return true
    else
      flash[:warning] << "Amount owed by debtors must equal the amount owed to creditors"
      return false
    end
  end
  
  def form_from_debt(debt)
    form_values = {}
    form_values[:name] = debt.name
    #form_values[:tags] = debt.tags
    form_values[:date] = debt.date
    form_values[:debt_id] = debt.id
    form_values[:permissions_level] = debt.permissions_level
    form_values[:creditor_selector_data] = []
    form_values[:debtor_selector_data] = []
    debt.user_debts.each do |user_debt|
      if(user_debt.debit_amount > 0)
        form_values[:debtor_selector_data] << { :selection_id => user_debt.user_id, :amount => user_debt.debit_amount }
      end 
      if(user_debt.credit_amount > 0)
        form_values[:creditor_selector_data] << { :selection_id => user_debt.user_id, :amount => user_debt.credit_amount }
      end
    end
    form_values[:description] = debt.description
    return form_values
  end
end
