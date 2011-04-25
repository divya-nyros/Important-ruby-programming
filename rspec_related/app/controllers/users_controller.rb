class UsersController < ApplicationController
  before_filter :redirect_affiliate_user
  
  make_resourceful do
    actions :all #:new, :edit, :update, :show, :index, :destroy
		before :new do
      current_object.phone_numbers.build if current_object.phone_numbers.empty?
      current_object.websites.build if current_object.websites.empty?
      current_object.addresses.build if current_object.addresses.empty?
    end
	end

  def edit
    if current_object.type == "Affiliate"
      redirect_to edit_affiliate_path(current_object)
    else
      current_object.phone_numbers.build if current_object.phone_numbers.empty?
      current_object.websites.build if current_object.websites.empty?
      current_object.addresses.build if current_object.addresses.empty?
    end
  end

  def create
    if !params[:user][:type].nil? && params[:user][:type] == "Affiliate"
      flash[:notice] = "Cannot create affiliate here"
      redirect_to :controller => :affiliate, :action => :new
    else
      params[:user][:type] = "User"
      params[:user][:parent_id] = nil

      @user = User.new(params[:user])

      if @user.save
        redirect_to :action => :index
      else
        render :action => :new
      end
    end
  end

  def destroy
    if User.count(:conditions => ["type = ?", "User"]) == 1 || current_user.id.to_s == params[:id]
      flash[:error] = "You cannot delete yourself!"
      redirect_to :action => :index
    else
      User.delete(params[:id])
      redirect_to :action => :index
    end
  end

  def update
    @user = User.find(params[:id])

    # Redirect if current editing user is affiliate.
    if @user.type == "Affiliate"
      redirect_to :controller => :affiliate, :action => :edit, :id => @user.id

      return
    end

    # Make sure that user has no parents.
    @user.update_attributes(params[:user])
    @user.update_attribute(:parent_id, nil)

    if @user.save
      flash[:notice] = "User was updated successfully"
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end
  
  def deleted
    render :action => :index
  end
  
  def permanently_delete
    # completely destroy the user
    @current_object = current_model.find_with_deleted(params[:id])
    current_object.destroy!
    flash[:notice] = "User has been permanently deleted"
    redirect_to :action => :deleted
  end
  
  def restore
    # undelete the user
    @current_object = current_model.find_with_deleted(params[:id])
    current_object.undelete!
    flash[:notice] = "User has been successfully restored"
    redirect_to user_path(current_object)
  end

  protected

  def current_objects
    options = {
      :page     => params[:page] || 1,
      :per_page => 25,
      :order    => params[:sort].blank? ? "first_name, last_name" : params[:sort]
    }
    options[:order] << " desc" if options[:order].to_s == 'created_at'
    options[:include] = [:phone_numbers]

    if params[:search].nil?
      params[:search] = { :type => "User" }
    end

    @current_objects ||= if action_name == 'deleted'
      current_model.paginate_with_deleted(:all, options.merge(:conditions => "deleted_at is not null"))
    elsif params[:search]
      current_model.search(params[:search], options)
    else
      current_model.paginate(options)
    end
  end
end