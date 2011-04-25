class DashboardController < ApplicationController
  def index
    # display recent activity
    if current_user.type == "User"
      @affiliates = Affiliate.all(:order => "created_at DESC", :limit => 10)
      @attendees = Attendee.all(:order => "created_at DESC", :limit => 20)
    else
      @attendees = Attendee.all(:conditions => ["affiliate_id = ?", current_user.id], :order => "created_at DESC", :limit => 20)
    end
  end
end
