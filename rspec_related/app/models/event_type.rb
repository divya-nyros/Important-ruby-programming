class EventType < ActiveRecord::Base
  has_many :events, :foreign_key => :type_id
  has_many :invitations

  validates_presence_of :name
end
