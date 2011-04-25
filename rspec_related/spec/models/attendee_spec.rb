require File.dirname(__FILE__) + '/../spec_helper'

describe Attendee do
  it "should be an instance of Attendee" do
    Attendee.new.should be_an_instance_of(Attendee)
  end
end
