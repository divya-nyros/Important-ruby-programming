require File.dirname(__FILE__) + '/../../spec_helper'

describe Api::AffiliatesController do 

  describe "POST: create" do

    it "should create a new affiliate" do
      valid_params = valid_affiliate_params
      lambda{post :create, valid_params}.should change(Affiliate, :count).by(1)
    end

    context "when successful" do
      before(:each) do
        @affiliate = Factory(:affiliate)
        Affiliate.stub!(:new).and_return(@affiliate)
      end

      it "should add a valid phone number" do
        @phone = Factory(:mobile_phone, :contactable => @affiliate)
        @affiliate.phone_numbers.should_receive(:build).and_return(@phone)
        
        post :create, valid_affiliate_params_with_phone_number_and_address
        @affiliate.phone_numbers.include?(@phone).should be_true
      end

      it "should add a valid address" do
        @address = Factory(:address, :addressable => @affiliate)
        @affiliate.addresses.should_receive(:build).and_return(@address)
        
        post :create, valid_affiliate_params_with_phone_number_and_address
        @affiliate.addresses.include?(@address).should be_true
      end
    end

    context "when unsuccessful" do
      before(:each) do
        @affiliate_params = {:affiliate =>{:first_name =>'',:last_name => ''}}
      end

      it "render the oops templete " do
        post :create, @affiliate_params   
        response.should render_template('oops')          
      end

      it "does not create an affiliate record" do
        lambda{post :create,@affiliate_params}.should_not change(Affiliate, :count)
      end
    end
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


