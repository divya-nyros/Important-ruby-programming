require File.dirname(__FILE__) + '/../spec_helper'
describe DashboardController do
  
include Devise::TestHelpers
 before(:each) do
      sign_in Factory(:admin)
    end

 describe "GET: index" do     
     context "when current user login as user" do
                 it "should be successful" do
                   get :index
                   response.should be_true
                 end
                
                  it "render the 'index' template" do
                   create_user    
                   response.should render_template('index')
                 end

                 it "should list all the affliates" do 
                    @params = {:limit=>10, :order=>"created_at DESC"}
                    Affiliate.should_receive(:find).with(:all, @params)
                    get :index
                 end
                
                  it "should list all the attendees" do 
                    @params = {:limit=>20, :order=>"created_at DESC"}
                    Attendee.should_receive(:find).with(:all, @params)
                    get :index
                 end
      end
               
               
     context "when current user not login as user" do
            it "should list all the attendees" do 
                 User.any_instance.expects(:User?).returns(false)
                @params = {:limit=>20, :order=>"created_at DESC"}
                Attendee.should_receive(:find).with(:all, @params)
                get :index
            end
      end
               
  end
  

  def create_user(options = {})
    get :index, :user => { :first_name => 'quire', :last_name => 'sarma',:email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire',:type => 'User' }.merge(options)
  end

end

