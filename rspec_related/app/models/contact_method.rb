class ContactMethod < ActiveRecord::Base
  belongs_to :contactable, :polymorphic => true
  
  # validates_presence_of :contactable
  
  def self.categories
    []
  end
  
  def to_s
    data.to_s rescue ""
  end
end
