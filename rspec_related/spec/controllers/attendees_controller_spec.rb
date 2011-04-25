require File.dirname(__FILE__) + '/../spec_helper'
describe AttendeesController do
include Devise::TestHelpers
  describe "Login as user and post attendee" do
      before(:each) do
        sign_in Factory(:admin)
      end
      #####Spec for the new method start#########
      describe "Reschedule vip" do
        before(:each) do
          @event = Factory(:event)
          @new_event = Factory(:new_event)
          @attendee = Factory(:attendee)
          @attendee.events << @event
          @guest = Factory(:guest)
          @guest.events << @event
          @event_registration = @attendee.event_registrations.for_event(@event).first
          @event_registration.update_attribute(:guest, @guest.id)
          @event_params = {:id => @new_event.id, :old_id => @event.id}
          @attendee_params = {:first_name => "first", :last_name => "last", :email => @attendee.email}
        end

        it "should also reschedule guest" do
          put :update, :id => @attendee.id, :event => @event_params, :attendee => @attendee_params
          response.should redirect_to(:action => :show)
          @attendee.event_registrations.for_event(@event).first.should be_nil
          @attendee.event_registrations.for_event(@new_event).first.should_not be_nil
          @attendee.event_registrations.for_event(@new_event).first.guest.should == @guest.id
          @guest.event_registrations.for_event(@event).first.should be_nil
          @guest.event_registrations.for_event(@new_event).first.should_not be_nil
          @guest.event_registrations.for_event(@new_event).first.guest_of.should == @attendee.id
        end
      end
      #####Spec for the new method end#########

  end
end

def valid_attendee_params
  {
    'attendee' => Factory.attributes_for(:attendee).stringify_keys!
  }
end
