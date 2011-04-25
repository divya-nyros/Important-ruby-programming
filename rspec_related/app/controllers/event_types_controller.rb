class EventTypesController < ApplicationController
  before_filter :redirect_affiliate_user
  
  make_resourceful do
    actions :all
    
    response_for :create do |format|
      format.html { 
        flash[:notice] = "Create successful!"
        redirect_to objects_path 
      }
    end
  end
  
  def current_objects
		options = {
			:page     => params[:page] || 1,
			:per_page => 25,
			:order    => params[:sort].blank? ? "name" : params[:sort]
		}
		
		@current_objects ||= current_model.paginate(options)
	end
end
