class List < ActiveRecord::Base
  belongs_to :events
  
  def self.group_names
    List.all(:select => "DISTINCT(group_name) AS group_name", :order => 'group_name').map(&:group_name)
  end
end
