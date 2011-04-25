class ActivitiesController < ApplicationController
  make_resourceful do
    belongs_to :attendee #TODO: other polymorphic associations
    actions :create, :destroy
    
    before :create do
      current_object.actor = current_user
    end
    
    response_for :create_fails, :destroy, :destroy_fails do
      redirect_to parent_object
    end

    response_for :create do
      render :partial => "app/views/activities/show.html.erb"
    end
  end
end
