require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventType do
  describe 'Create event type' do
    it "should increment event type by 1" do
      lambda {
        Factory.create(:event_type)
      }.should change(EventType, :count).by(1)
    end

    it "should require a name" do
      event_type = Factory.build(:event_type, :name => nil)
      event_type.should_not be_valid
      event_type.should have(1).error_on(:name)
    end
  end
end
