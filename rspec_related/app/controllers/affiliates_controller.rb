class AffiliatesController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [ :resend ]
  before_filter :redirect_affiliate_user, :except => [:edit, :update]
  
  make_resourceful do
    actions :all
    
    before :new do
      # build empty associations for the form
      current_object.phone_numbers.build if current_object.phone_numbers.empty?
      current_object.websites.build if current_object.websites.empty?
      current_object.addresses.build if current_object.addresses.empty?
    end
    
    before :create, :update do
      # master = Affiliate.find(object_parameters[:parent]) unless object_parameters[:parent].blank?
      # current_object.parent = master
    end
  end

  def edit
    if current_user.id.to_s != params[:id] && current_user.type == "Affiliate"
      redirect_to :action => :edit, :id => current_user.id
    else
      current_object.phone_numbers.build if current_object.phone_numbers.empty?
      current_object.websites.build if current_object.websites.empty?
      current_object.addresses.build if current_object.addresses.empty?
    end
  end

  def update
    if current_user.type == "Affiliate"
      @affiliate = Affiliate.find(current_user.id)
    else
      @affiliate = Affiliate.find(params[:id])
    end

    @affiliate.update_attributes(params[:affiliate])
    
    if @affiliate.save
      if current_user.type == "Affiliate"
        flash[:notice] = "Your account was saved successfully"
        redirect_to :controller => :dashboard, :action => :index
      else
        flash[:notice] = "Affiliate was updated successfully"
        redirect_to :action => :index
      end
    else
      render :action => :edit
    end
  end

  def search
    if current_objects.empty?
      flash.now[:warning] = "No Affiliates matched your search."
    end
    render :action => :index
  end
  
  def resend
    if current_object = current_model.find_by_email(params[:email].strip.downcase)
      current_object.resend_welcome!
    end
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
      
      @current_objects ||= if params[:search]
        current_model.search(params[:search], options)
      else
        current_model.paginate(options)
      end
    end
end
