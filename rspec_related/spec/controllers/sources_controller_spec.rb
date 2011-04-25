require File.dirname(__FILE__) + '/../spec_helper'
describe SourcesController do
  include Devise::TestHelpers
  describe "Login as user and post sources" do
    before(:each) do
      sign_in Factory(:admin)
    end

    it "should create source with valid params" do
     create_source
      response.should redirect_to(sources_path)
    end

    it "should fail with invalid params" do
       create_source({:name => nil})
      assigns[:source].errors.length.should == 1
      assigns[:source].errors.on(:name).should be_true
    end
  end

  describe "Login as affiliate and post sources" do
    before(:each) do
      sign_in Factory(:affiliate)
    end

    it "should redirect to sources" do
     create_source
      response.should redirect_to(sources_path)
    end
  end

  describe "Non-login user post source" do
    it "should redirect to signin path" do
       create_source
      response.should redirect_to(new_user_session_path + "?unauthenticated=true")
    end
  end

  def create_source(options = {})
    post :create, :source => {:name => 'test', :description => 'Leads generated from ads on Craigslist'}.merge(options)
  end
end
