require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Api::InfusionController do
describe "POST: create_affiliate" do
  context "when successful" do
      
      before(:each) do
          @affiliate = mock_model(Affiliate)
          Affiliate.stub!(:find).and_return(@affiliate)
          @phone =  mock_model(PhoneNumber)
          @phone.stub!(:affiliate).and_return(@affiliate)
          @address =  mock_model(Address)
          @address.stub!(:affiliate).and_return(@affiliate)
          @website =  mock_model(Website)
          @website.stub!(:affiliate).and_return(@affiliate)
         #~ @affiliate = {:affiliate =>{:first_name =>'DivyaDasari',:last_name => 'Dasari123',:email => 'divya_nyros123@yahoo.com',:affiliate_code =>'12345623'}}
       end  
       
        it "should assign an @affiliate variable" do
        post :create_affiliate, valid_params_with_affiliate
        assigns[:affiliate].should_not be_nil
        assigns[:affiliate].should be_kind_of(Affiliate)
      end
      
       it "should create a valid affiliate" do
           lambda{post :create_affiliate,valid_params_with_affiliate}.should change(Affiliate, :count).by(1)
     end
 
        it "should build a valid address" do
         post :create_affiliate, valid_params_with_phone_number_and_address.merge(valid_params_with_affiliate)
          @address.should_not be_nil
        end
        
        it "should build a valid phone numbers" do
         post :create_affiliate, valid_params_with_phone_number_and_address.merge(valid_params_with_affiliate)
           @phone.should_not be_nil
         end
         
          it "should build a valid website address" do
         post :create_affiliate, valid_params_with_phone_number_and_address.merge(valid_params_with_affiliate)
           @website.should_not be_nil
         end
       end
       
       
      context "when unsuccessful" do
         before(:each) do
             @affiliate = {:affiliate =>{:first_name =>'DivyaDasari',:last_name => 'Dasari123',:email => 'divya_nyros123@yahoo.com',:affiliate_code =>'12345623'}}
          end
          
          it "does not create an affiliate record" do
             lambda{post :create_affiliate,@affiliate}.should_not change(Affiliate, :count)
          end
      end
end
end


def valid_params_with_affiliate
  {
    #~ 'affiliate' => Factory.attributes_for(:affiliate).stringify_keys!
 "AffiliateTermsandConditions" => "Yes I agree to the Affiliate Terms and Conditions" , 
"City" =>"Davenport",
"StreetAddress1" =>"133 Sweet Bay St.",
"Groups"=> "176",
"Signature" => "NSM Error getting value: com.infusion.crm.modules.contact.Contact.getSignature()",
"SSNTID" => "430-39-1837",
"OwnerID" => "0",
"LastName" => "Cartwright",
"PostalCode"=> "33837",
"DateCreated" => "2010-09-02 21:45:11.0",
"HTMLSignature"=> "NSM Error getting value: com.infusion.crm.modules.contact.Contact.getHTMLSignature()",
"Address2Street1" => "133 Sweet Bay St.",
"FirstName" =>"Jason",
"State2" => "FL",
"Id"=> "114",
"CompanyID" => "0",
"PostalCode2"=> "33837",
"Website" => "www.yoursitedonerightnow.com",
"LastUpdated"=> "2010-09-02 21:47:32.0",
"Company" =>" Enspired Software",
"City2"=> "Davenport",
"Phone1" => " (863) 438-1844",
"State"=> "FL",
"Email" => "jason@enspiredsoftware.com",
"CreatedBy"=> "5",
"AssistantName" => "Fatima",
"AssistantEmail" => "fatima@enspiredsoftware.com",
"LastUpdatedBy"=> "5"
    
    
  }
end
def valid_params_with_phone_number_and_address
    {
      "phone_number" => Factory.attributes_for(:mobile_phone).stringify_keys!,
      "address" => Factory.attributes_for(:address).stringify_keys!,
      "website" => Factory.attributes_for(:work_website).stringify_keys!
    }

end

