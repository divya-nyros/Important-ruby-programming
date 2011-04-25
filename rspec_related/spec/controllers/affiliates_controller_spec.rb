require File.dirname(__FILE__) + '/../spec_helper'
describe AffiliatesController do 
include Devise::TestHelpers
describe "Login as user and post affiliate" do
    before(:each) do
      sign_in Factory(:admin)
    end
    #####Spec for the new method start#########
    describe "GET: new" do
              it "should be successful" do
              get 'new'
              response.should be_success
              end
            it "should render templete new" do
              get 'new'
              response.should render_template('new')
              end
       
              it "should assigns a new affiliate" do
              get 'new'
              assigns[:affiliate].should_not be_nil  
              assigns[:affiliate].should be_kind_of(Affiliate)
              assigns[:affiliate].should be_new_record
            end
     end
  #####Spec for the new method end#########   

end
end

def valid_affiliate_params
  {
    'affiliate' => Factory.attributes_for(:affiliate).stringify_keys!
  }
end

def valid_affiliate_params_with_phone_number_and_address
  valid_affiliate_params.merge(
    {
      "phone_number" => Factory.attributes_for(:mobile_phone).stringify_keys!,
      "address"      => Factory.attributes_for(:address).stringify_keys!
    }
  )
end


