require File.dirname(__FILE__) + '/../../spec_helper'

describe Api::ApiController do
  describe "when determing the source based on POST params" do
    it "should default to :unknown" do
      controller.params = {}
      controller.determine_source.should == :unknown
    end

    it "should detect InfusionSoft" do
      controller.params = { "Signature"=>"NSM Error getting value: com.infusion.crm.modules.contact.Contact.getSignature()" }
      controller.determine_source.should == :infusion_soft
    end
    
  end
end
