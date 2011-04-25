require File.dirname(__FILE__) + '/../spec_helper'

describe EmailAddress do
  before(:each) do
    @email_address = EmailAddress.new
  end
  
  it_should_behave_like "ContactMethods"
  
  it "should be an instance of EmailAddress" do
    @email_address.should be_an_instance_of(EmailAddress)
  end
  
  it "should return a list of valid categories" do
    EmailAddress.categories.should == %w( work home other )
  end
end
