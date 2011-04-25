require File.dirname(__FILE__) + '/../spec_helper'
describe EventsController do
include Devise::TestHelpers

  describe "Login as user and create a event" do
    before(:each) do
      sign_in Factory(:admin)
    end
        describe "GET: new" do
              it "should be successful" do
              get 'new'
              response.should be_success
              end
            it "should render templete new" do
              get 'new'
              response.should render_template('new')
              end
       
              it "should assigns a new event object" do
              get 'new'
              assigns[:event].should_not be_nil  
              assigns[:event].should be_kind_of(Event)
              assigns[:event].should be_new_record
            end
     end
            
      describe "Post: create" do   
          context "when successful" do
            before(:each) do
              @event_params = {:event =>{:name =>'Divya',:description => 'sasasasas',:start_date =>Date.today + 14,:start_time =>'08:00',
              :end_date=>Date.today + 14,:end_time=>'10:00',:phone_numbers_attributes =>[{:category=>"mobile",
               :data=>"9876543210"}], :addresses_attributes =>[{:street=>"123",
               :city=>"Davenport",:state=>"FL",:zip=>"33837",:category=>"home"}],:websites_attributes =>[{:category=>"work",
               :data =>"www.yoursitedonerightnow.com"}] }}
            end
                     it "should assign a @event variable" do
                       post :create,  @event_params
                       assigns[:event].should_not be_nil
                      assigns[:event].should be_kind_of(Event)
                    end   
                        
                       it "should create a new event with nested attributes" do
                        lambda{
                        lambda{
                        lambda{
                        lambda{post :create, @event_params
                        }.should change(Event, :count).by(1)
                        }.should change(PhoneNumber, :count).by(1)
                        }.should change(Address, :count).by(1) 
                        }.should change(Website, :count).by(1)                          
                   end  

                          
          end
      end
            
         describe "GET: edit" do  
             before(:each) do
               @event = Factory(:event)
             end
                it "should be successful" do
                  get 'edit', :id => @event
                  response.should be_success
                end
        end

      describe "PUT: publish" do  
             before(:each) do
               @event = Factory(:event)
             end
                it "state should be published" do
                  put 'publish', :id => @event,:state =>"published"
                 response.should have_text('Published')
                end
        end

describe "PUT: Unpublished" do  
             before(:each) do
               @event = Factory(:event)
             end
                it "state should be unpublished" do
                  put 'unpublish', :id => @event,:state =>"unpublished"
                 response.should have_text('Unpublished')
                end
              end
              
describe "PUT: expire" do  
             before(:each) do
               @event = Factory(:event)
             end
                it "state should be published" do
                  put 'expire', :id => @event,:state =>"expired"
                 response.should have_text('Expired')
            end
end


describe "GET: closed" do  
                it "should be closed" do
                  get 'closed'
                  response.should render_template('index')          
            end
end
          
describe "GET: all" do  
                it "should be all" do
                  get 'all'
                  response.should render_template('index')          
            end
end

describe "GET: search" do  
   before(:each) do
               @event = Factory(:event)
   end
          context "when successful" do
                    it "should search an event" do
                      get 'search',:search => {:name =>'New event'}
                      response.should render_template('index')          
                    end
              end
               context "when unsuccessful" do
                      it "should not search an event" do
                      Event.any_instance.expects(:empty?).returns(true)
                      get 'search',:search => {:name =>''}
                      response.should render_template('index')  
                      flash.now[:warning] == 'No Event matched your search.'  
                     end
              end
end



  describe "GET: checkin" do  
       before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
      end
               context "checkin when empty" do
                    it "should checkin a event" do
                        Event.any_instance.expects(:search?).returns(true)
                        get 'checkin', :id => @event.id
                       response.should be_success        
                     end
                end
                   
                 context "checkin with out empty" do
                   it "should checkin without an event" do
                        Event.any_instance.expects(:search?).returns(false)
                        get 'checkin', :id => @event.id,:search => {:name =>'New event'}
                       response.should be_success        
                     end
                   end           
    end
            
 describe "GET: confirm" do  

      before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
      
      it "should confirm an attendee to an 'Event Check-In' " do              
            User.any_instance.expects(:User?).returns(true)    
            get 'do_confirm',:id => @event.id, :attendee_id => @attendee.id       
            @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
             response.should have_text('Confirmed')
      end
  end
  
  describe "GET: cancel" do  
     before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
       it "should cancel an attendee to an 'Event Check-In' " do
           User.any_instance.expects(:User?).returns(true)
           get'do_cancel',:id => @event.id, :attendee_id => @attendee.id
           @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
          response.should have_text('Canceled')
         end
  end
    describe "GET: do_checkin" do  
     before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
       it "should checkin an attendee to an 'Event Check-In' " do
           User.any_instance.expects(:User?).returns(true)
           get'do_checkin',:id => @event.id, :attendee_id => @attendee.id
           @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
          response.should have_text('Attended')
         end
  end
    describe "GET: noshow" do  
     before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
       it "should checkin an attendee to an 'Event Check-In' " do
           User.any_instance.expects(:User?).returns(true)
           get'do_noshow',:id => @event.id, :attendee_id => @attendee.id
           @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
          response.should have_text('No showed')
         end
  end
 describe "GET: otf" do  
     before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
       it "should checkin an attendee to an 'Event Check-In' " do
           User.any_instance.expects(:User?).returns(true)
           get'do_otf',:id => @event.id, :attendee_id => @attendee.id
           @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
          response.should have_text('Undecided')
         end
       end
       
 describe "GET: purchase" do  
     before(:each) do
        @event = Factory(:event)
        @attendee = Factory(:attendee)
        Attendee.stub!(:new).and_return(@attendee) 
        @event_registrations = mock(Array)
        @event_registration.stub!(:for_event).and_return([])
        @attendee.stub!(:event_registrations).and_return(@event_registration)
      end
       it "should checkin an attendee to an 'Event Check-In' " do
           User.any_instance.expects(:User?).returns(true)
           get'do_purchase',:id => @event.id, :attendee_id => @attendee.id
           @activity = Factory(:activity, :actionable => @attendee)            
            @attendee.activities.include?(@activity).should be_true
          response.should have_text('Purchased')
         end
  end 
       
describe "POST: duplicate" do  
             before(:each) do
               @event = Factory(:event)
             end
               
        it "should create a duplicate event" do
          get 'duplicate',:id => @event.id
           @event_params = {:id => @event.id,:name =>@event.name,:description =>@event.description,:start_date =>@event.start_date,:start_time =>@event.start_time,
    :end_date=>@event.end_date,:end_time=> @event.end_time}
         lambda{post :duplicate, @event_params}.should change(Event, :count).by(1) 
         end

end
        
describe "GET: set_visible" do  
    before(:each) do
               @event = Factory(:event)
             end
    context "should be visible as public" do
                it "should update as public " do
                  Event.any_instance.expects(:public?).returns(true)
                  get 'set_visible',:id => @event.id, :value => 'public'
                  response.should have_text('Public')          
                end
              end
             context "should be visible as private" do
                it "should update as public " do
                  Event.any_instance.expects(:public?).returns(false)
                  get 'set_visible',:id => @event.id, :value =>'private'
                  response.should have_text('Private')          
                end
        end   
              
end  
describe "GET: export" do
   it "should export an event" do
     pending
   end
end
describe "GET: update_state_select" do
   it "should update_state_select for a event" do
     pending
   end
 end
 
end

     
  describe "Non-login user post to event" do
    it "should redirect to signin path" do
      post :create, valid_params_with_event
      response.should redirect_to(new_user_session_path + "?unauthenticated=true")
    end
  end
end
    def valid_params_with_event
  {
    'event' => { 'id' => 1 },
    'attendee' => Factory.attributes_for(:attendee).stringify_keys!
  }
end
 