class Activity < ActiveRecord::Base
  ACTIVITY_CATEGORIES = %w( phone_call email comment ).freeze
  
  belongs_to :actionable, :polymorphic => true
  belongs_to :actor, :class_name => "User"
  
  def self.categories
    ACTIVITY_CATEGORIES
  end
  
  def self.search(conditions)
    find(:all, :conditions => conditions, :select => "actionable_id")
  end

end
