require File.dirname(__FILE__) + '/../spec_helper'

describe EventTypesController do
  include Devise::TestHelpers

  describe "Login as user and post to event_types" do
    before(:each) do
      sign_in Factory(:admin)
    end

    it "should create event_type with valid params" do
      create_event_type
      response.should redirect_to(event_types_path)
    end

    it "should fail with invalid params" do
      create_event_type({:name => nil})
      assigns[:event_type].errors.length.should == 1
      assigns[:event_type].errors.on(:name).should be_true
    end
  end

  describe "Login as affiliate and post to event_types" do
    before(:each) do
      sign_in Factory(:affiliate)
    end

    it "should redirect to dashboard" do
      create_event_type
      response.should redirect_to(:controller => :dashboard, :action => :index)
    end
  end

  describe "Non-login user post to event_types" do
    it "should redirect to signin path" do
      create_event_type
      response.should redirect_to(new_user_session_path + "?unauthenticated=true")
    end
  end

  def create_event_type(options = {})
    post :create, :event_type => {:name => 'test', :description => 'Create event type for event'}.merge(options)
  end
end
