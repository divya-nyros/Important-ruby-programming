class Address < ActiveRecord::Base
  ADDRESS_CATEGORIES = %w( home work other )
  
  belongs_to :addressable, :polymorphic => true
  
  def categories
    ADDRESS_CATEGORIES
  end

  def self.search(conditions)
    find(:all, :conditions => conditions, :select => "addressable_id")
  end
end
