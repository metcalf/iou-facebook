class PaymentsController < ApplicationController

  
  def results
    
    finder = {:page => params[:page], 
              :per_page => 15, 
              :order => 'date DESC',
              :conditions => ['TRUE']}
    
    if(params[:payor_id])
      payor_id = params[:payee_id]
      payee_id = @current_user.id
    elsif(params[:payee_id])
      payee_id = params[:payee_id]
      payor_id = @current_user.id
    end
    
    if(payee_id != nil)
      finder[:conditions][0] = '(payor_id == ? AND payee_id == ?) AND ' + finder[:conditions][0]
      finder[:conditions].insert(1, payor_id)
      finder[:conditions].insert(2, payee_id)
    else
      finder[:conditions][0] = '(payor_id = ? OR payee_id = ?) AND ' + finder[:conditions][0]
      finder[:conditions].insert(1, @current_user.id)
      finder[:conditions].insert(2, @current_user.id)
    end
  
    @payments = Payment.paginate(finder)
  end
  
  def edit
    if(params.has_key?(:start))
      if(params.has_key?(:other_user_id))
        @other_user_id = params[:other_user_id]
      end
      @ajax = true
      render :partial => 'edit'
    elsif request.post?
      params[:date] = Date.civil(params[:payment]['date(1i)'].to_i,params[:payment]['date(2i)'].to_i,params[:payment]['date(3i)'].to_i)
      begin
        result = edit_add_payment(params)
        redirect_to :action => :results, :notice => "Payment was saved successfully."
      rescue
        redirect_to :action => :results, :warning => flash[:warning]
      end
    else
      # Should never reach this point... include a redirect just in case
      redirect_to :back
    end
  end
  
  def delete
    # Check for an ID
    redirect_to :action => :results, :warning => "You must provide a payment to delete" and return unless params.has_key?(:id)
    
    # Find the payment
    payment = nil
    begin
      payment = Payment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => :results, :warning => "Payment to be deleted does not exist"
      return
    end
    
    # Confirm the current user is allowed to delete
    redirect_to :action => :results, :warning => "You are not allowed to delete that payment" and return unless payment.editor?(@current_user)
    
    # Delete
    payment.destroy
    redirect_to :action => :results, :notice => "Payment was deleted successfully"
  end
  
  private
  
  def edit_add_payment(params)
    # Find payor and payee
    payment = nil
    user_ids = [User.current_user.id]
    Payment.transaction do
      if(params.has_key?(:id) and not params[:id].empty?)
        begin
          payment = Payment.find(params[:id])
          user_ids = user_ids + [payment.payor_id, payment_payee_id]
          if(not params.has_key?(:other_user_id) or params[:other_user_id].empty?)
            params[:other_user_id] = payment.payor_id == @current_user.id ? payment.payee_id : payment.payor_id
          else
            user_ids << params[:other_user_id]
          end
          
        rescue ActiveRecord::RecordNotFound
          flash[:warning] << "The specified payment does not exist"
          raise "0"
        end
        
        if(not payment.editor?(@current_user))
          flash[:warning] << "You are not permitted to edit this payment"
          raise "0"
        end 
      else
        payment = Payment.new
      end
      
      if(params[:direction] == 'payor')
        payor = @current_user
        payee = User.find_or_create_by_id(params[:other_user_id])
      else
        payee = @current_user
        payor = User.find_or_create_by_id(params[:other_user_id])
      end
      
      payment.payor_id = payor.id
      payment.payee_id = payee.id
      
      attribs = {:date => params[:date], :notes => params[:notes].to_s, :transaction_type => Payment::EXTERNAL_PAYMENT, :amount => params[:amount].to_f }
      
      if(not payment.update_attributes(attribs))
        flash[:warning] += payment.errors.full_messages
        raise "0"
      end
      
      if(not payment.save)
        flash[:warning] += payment.errors.full_messages
        raise "0"
      end
    end
    
    user_ids.uniq.each { |user_id| User.update_outstandings(user_id, user_ids) }
    
    return payment
  end
  
  def form_from_payment(payment)
    form_values = {}
    form_values[:date] = payment.date
    form_values[:notes] = payment.notes
    if(@current_user.id == payment.payor_id)
      form_values[:direction] = 'payor'
    else 
      form_values[:direction] = 'payee'
    end
    form_values[:amount] = payment.amount
    
    return form_values
  end

end
