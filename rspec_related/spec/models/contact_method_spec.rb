require File.dirname(__FILE__) + '/../spec_helper'
require "set"

shared_examples_for "ContactMethods" do
  let(:contact_method) { described_class.new }
  
  it "should be contactable" do
    contact_method.should respond_to(:contactable)
  end
  
  it "should return the data attribute for to_s" do
    contact_method.data = "some data value"
    contact_method.to_s.should == "some data value"
  end
  
  it "should return a collection of categories" do
    described_class.should respond_to(:categories)
    described_class.categories.should be_an_instance_of(Array)
  end
end

describe ContactMethod do
  before(:each) do
    @contact_method = ContactMethod.new
  end
  
  it "should be an instance of ContactMethod" do
    @contact_method.should be_an_instance_of(ContactMethod)
  end
  
  it_should_behave_like "ContactMethods"
end

