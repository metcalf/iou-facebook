class UsersController < ApplicationController

  def home
    @debts = Debt.find(:all, :conditions => ["debts.creator_id = ?", @current_user.id], :limit => 5, :order => "debts.date DESC")
  end

  def results
    @users = User.paginate({:page => params[:page], :per_page => 10}.merge(@current_user.friend_find))
  end
  
  def view  
    begin
      if(@current_user.fb_user.friends_with?(params[:id]))
        @person = User.find(params[:id])
      else    
        flash[:warning] << "Sorry, you do not have permission to view this user's profile"
        redirect_to :action => :results
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to :results
    end
  end
  
end