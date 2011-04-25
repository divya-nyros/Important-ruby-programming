require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Api::EventsController do

     def setup
        @controller = Api::EventsController.new
        @request    = ActionController::TestRequest.new
        @response   = ActionController::TestResponse.new
    end

#The index action finds all events, assigns the resulting array to @events, and renders the index template:
######### INDEX #######
describe Api::EventsController do
  before :each do
    @event = mock_model(Event)
    Event.stub!(:new).and_return(@event)
  end

  describe "GET: index" do
    before :each do
      @events = Array.new { mock_model(Event) }
      Event.stub!(:find).and_return(@events)
    end

    
    it "should be successful" do
      get :index,:format=>:xml
     should respond_to(:index)
     end

       it "should load a list of all events" do
        #~ Event.should_receive(:find).and_return(@events)
        Event.should_receive(:find).any_number_of_times
        get :index,:format=>:xml
      end

    it "should assign @events" do
      get :index,:format=>:xml
      assigns[:events].should == @events
    end
    
    it "should render the index template" do
      get :index,:format=>:html
       #~ @response.should render_template(:index)
         #~ @response.should redirect_to(events_url(@events))
    end
  end
end
 ######### INDEX END  ####### 


############  SHOW ########
 
   describe "GET: show" do
    before :each do
      Event.stub!(:find).and_return(@events)
    end

    it "should load the requested events" do
      Event.should_receive(:find).and_return(@events)
      get :show,:format=>:xml, :id => 1
    end

    it "should assign @event" do
      get :show, :format=>:xml,:id => 1
      assigns[:events].should == @events
    end

    it "should render the show template" do
      get :show,:format=>:xml,:id => 1
      #~ @response.should render_template(:show)
    end
  end
 
 #############  SHOW END ########


############  Map ########
 
   describe "GET: map" do
    before :each do
      Event.stub!(:find).and_return(@events)
    end

    it "should load the requested event maps" do
      Event.should_receive(:find).any_number_of_times
      get :map, :format=>:xml
    end

    it "should assign @event" do
      get :map, :format=>:xml
      assigns[:events].should == @events
    end

    it "should render the show template" do
      get :map,:format=>:xml
      #~ @response.should render_template(:show)
    end
  end
 
 #############  Map END ########

############  In ########
 
   describe "GET: In" do
    before :each do
      Event.stub!(:find).and_return(@events)
    end

    it "should load the requested event maps" do
      Event.should_receive(:find).any_number_of_times
      get :in, :format=>:xml
    end

    it "should assign @event" do
      get :in, :format=>:xml
      assigns[:events].should == @events
    end

    it "should render the show template" do
      get :in,:format=>:xml
      #~ @response.should render_template(:show)
    end
  end
 
 #############  In END ########

end
