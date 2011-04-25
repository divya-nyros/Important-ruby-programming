require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it "should be an instance of User" do
    User.new.should be_an_instance_of(User)
  end
  
  it "should return first_name + last_name for name" do
    user = Factory(:user)
    user.name.should == "#{user.first_name} #{user.last_name}"
  end
  
  it "should normalize the email address" do
    email = Factory.next(:email).upcase
    user = Factory(:user, :email => email)
    user.email.should == email.downcase
  end
  
  context "when authenticating" do
    before(:each) do
      @email = Factory.next(:email)
      @user = Factory(:user, :email => @email)
    end
    
    it "should be case insensitive" do
      user = User.find_for_authentication(:email => @email.upcase)
      user.should == @user
    end
  end
  
  context "when destroying" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should release the email" do
      email = @user.email
      lambda {
        @user.destroy
      }.should change(@user, :email)
      @user.email.should == "deleted-#{email}"
    end
    
  end
end
