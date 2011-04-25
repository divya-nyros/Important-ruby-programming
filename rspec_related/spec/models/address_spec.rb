require File.dirname(__FILE__) + '/../spec_helper'

describe Address do
  it "should be an instance of Address" do
    Address.new.should be_an_instance_of(Address)
  end
end
