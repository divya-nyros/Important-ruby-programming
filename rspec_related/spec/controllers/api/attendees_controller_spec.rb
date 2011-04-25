require File.dirname(__FILE__) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../factories/attendees')
require File.expand_path(File.dirname(__FILE__) + '/../../factories/invitations')

describe Api::AttendeesController do
  describe "POST create" do
    before(:each) do
      @request.env['HTTP_REFERER'] = 'http://agi-backoffice.local/sessions/new'
    end
    
    context "with an invalid event" do
      before(:each) do
        @event = mock_model(Event)
        Event.stub!(:find).and_return(@event)
      end
      
      it "should fail without event params" do
        post :create, valid_params_with_event.merge('event' => nil)
        response.should render_template("oops")
        flash[:error].should == "Unable to process your registration"
      end
    end
    
    context "with valid params" do

      it "should redirect to specified url on success"
      
    end
    
    context "without an invitation" do
      context "for a non-existant attendee" do
        before(:each) do
          @event = mock_model(Event)
          @event.stub!(:public?).and_return(true)
          Event.stub!(:find).and_return(@event)
          
          @attendee = mock_model(Attendee)
          @attendee.stub!(:events).and_return([])
          
          @event_registrations = mock(Array)
          @event_registrations.stub!(:for_event).and_return([])
          @attendee.stub!(:event_registrations).and_return(@event_registrations)
        end
        
        it "should fail with invalid params" do
          Attendee.should_receive(:new).and_return(@attendee)
          @attendee.should_receive(:save).and_return(false)
          
          post :create, valid_params_with_event
          response.should render_template("oops")
          flash[:error].should == "Unable to process your registration"
        end
        
        it "should create an attendee from valid params" do
          params = valid_params_with_event
          Event.should_receive(:find).and_return(@event)
          Attendee.should_receive(:new).with(params['attendee']).and_return(@attendee)
          @attendee.should_receive(:save).and_return(true)
          
          post :create, params
        end
        
        it "should create a new event registration" do
          params = valid_params_with_event
          Attendee.should_receive(:new).with(params['attendee']).and_return(@attendee)
          @attendee.should_receive(:save).and_return(true)
          
          post :create, params
        end
        
      end
      
      context "for an existing attendee" do
        
        it "should create a new event registration" do
          params = valid_params_with_event
          post :create, params          
        end
        
        it "should ignore duplicate event registrations"
        
      end
    end
    
    context "with an invitation" do
      before(:each) do
        @event = mock_model(Event)
        @event.stub!(:public?).and_return(true)
        Event.stub!(:find).and_return(@event)
        
        @attendee = mock_model(Attendee)
        @attendee.stub!(:save).and_return(true)
        @attendee.stub!(:events).and_return([])
        Attendee.stub!(:new).and_return(@attendee)
        
        @event_registrations = mock(Array)
        @event_registrations.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registrations)
        
        @invitation = mock_model(Invitation)
        @invitation.stub!(:accept!).and_return(true)
      end
      
      it "should fail if invitation is invalid" do
        Invitation.should_receive(:find_by_code).and_return(nil)        

        post :create, valid_params_with_invitation
        response.should render_template("oops")
        flash[:error].should == "Invitation code is not valid"
      end
      
      it "should fail if invitation has already been used" do
        @invitation.should_receive(:accepted?).and_return(true)
        Invitation.should_receive(:find_by_code).and_return(@invitation)        

        post :create, valid_params_with_invitation
        response.should render_template("oops")
        flash[:error].should == "Invitation code has already been used"
      end
      
      it "should succeed with a valid invitation and redirect to :back if no :redirect_url given" do
        @invitation.should_receive(:accepted?).and_return(false)
        Invitation.should_receive(:find_by_code).and_return(@invitation)        

        post :create, valid_params_with_invitation
        response.should redirect_to('http://agi-backoffice.local/sessions/new')
      end

      it "should succeed with a valid invitation and redirect :redirect_url given" do
        @invitation.should_receive(:accepted?).and_return(false)
        Invitation.should_receive(:find_by_code).and_return(@invitation)

        redirect_url = "http://agi-backoffice.local/thank-you"
        post :create, valid_params_with_invitation.merge({:redirect_url => redirect_url})
        response.should redirect_to(redirect_url)
      end
            
      it "should mark invitation as accepted" do
        @invitation.should_receive(:accepted?).and_return(false)
        @invitation.should_receive(:accept!).and_return(true)
        Invitation.should_receive(:find_by_code).and_return(@invitation)        

        post :create, valid_params_with_invitation
      end
    end
    context "with private event" do
      before(:each) do
        @event = mock_model(Event)
        @event.stub!(:public?).and_return(false)
        Event.stub!(:find).and_return(@event)

        @attendee = mock_model(Attendee)
        @attendee.stub!(:save).and_return(true)
        @attendee.stub!(:events).and_return([])
        Attendee.stub!(:new).and_return(@attendee)

        @event_registrations = mock(Array)
        @event_registrations.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registrations)

        @invitation = mock_model(Invitation)
        @invitation.stub!(:accept!).and_return(true)
      end

      it "should suceed with an invitation" do
        @invitation.should_receive(:accepted?).and_return(false)
        Invitation.should_receive(:find_by_code).and_return(@invitation)

        post :create, valid_params_with_invitation
        response.should redirect_to(@request.env['HTTP_REFERER'])
      end

      it "should fail without an invitation" do
        post :create, valid_params_with_event
        response.should render_template("oops")
      end
    end
  end
end

def valid_params_with_event
  {
    'event' => { 'id' => 1 },
    'attendee' => Factory.attributes_for(:attendee).stringify_keys!
  }
end

def valid_params_with_invitation
  valid_params_with_event.merge(
    {
      'invitation' => Factory.attributes_for(:invitation).stringify_keys!
    }
  )
end