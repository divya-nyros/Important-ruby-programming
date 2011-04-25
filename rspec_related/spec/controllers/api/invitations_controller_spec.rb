require File.dirname(__FILE__) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../factories/event_types')
require File.expand_path(File.dirname(__FILE__) + '/../../factories/invitations')

describe Api::InvitationsController do
  context "InfusionSoft" do
    context "POST create" do
      context "with valid params" do
        before(:each) do
          @event_type = mock_model(EventType)
          EventType.stub!(:find).and_return(@event_type)
          @invitation = mock_model(Invitation)
          @invitation.stub!(:event_type).and_return(@event_type)
          @event_type.stub!(:registration_url).and_return("http://anyurl.com")
        end

        it "should create a new Invitation" do
          post :create, valid_infusion_params
          @invitation.should_not be_nil
        end
        
        it "should set the EventType" do
          post :create, valid_infusion_params
          assigns(:invitation).event_type.should_not be_nil
        end
      
        context "when determing to allow a guest" do
          it "should default to true" do
            post :create, valid_infusion_params.merge({"AllowGuest" => ""})
            assigns(:invitation).allow_guest.should be_true
          end

          it "should be determined by the AllowGuest param" do
            post :create, valid_infusion_params.merge({"AllowGuest" => "yes"})
            assigns(:invitation).allow_guest.should be_true

            post :create, valid_infusion_params.merge({"AllowGuest" => "no"})
            assigns(:invitation).allow_guest.should be_false
          end
        end
      end
    end
  end
end

def valid_infusion_params
  {
    "Signature"=>"NSM Error getting value: com.infusion.crm.modules.contact.Contact.getSignature()", 
    "StreetAddress1"=>"133 Sweet Bay St.", 
    "City"=>"Davenport", 
    "LastName"=>"Cartwright", 
    "OwnerID"=>"0", 
    "HTMLSignature"=>"NSM Error getting value: com.infusion.crm.modules.contact.Contact.getHTMLSignature()", 
    "DateCreated"=>"2011-02-19 17:24:48.0", 
    "Country"=>"United States", 
    "PostalCode"=>"33837", 
    "Id"=>"1780", 
    "State2"=>"FL", 
    "FirstName"=>"Jason", 
    "Address2Street1"=>"133 Sweet Bay St.", 
    "Country2"=>"United States", 
    "PostalCode2"=>"33837", 
    "CompanyID"=>"0", 
    "City2"=>"Davenport", 
    "LastUpdated"=>"2011-02-19 17:24:48.0", 
    "Email"=>"jason@enspiredsoftware.com", 
    "State"=>"FL", 
    "CreatedBy"=>"1", 
    "LastUpdatedBy"=>"1",
    "EventType" => Factory.attributes_for(:event_type)[:name],
    "AllowGuest" => "yes"
  }
end