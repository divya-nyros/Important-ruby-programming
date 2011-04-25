require File.dirname(__FILE__) + '/../spec_helper'

describe Affiliate do
  it "should be an instance of Affiliate" do
    Affiliate.new.should be_an_instance_of(Affiliate)
  end
end
