require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  it "should be an instance of Activity" do
    Activity.new.should be_an_instance_of(Activity)
  end
end
