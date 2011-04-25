class Source < ActiveRecord::Base
  validates_length_of :name, :within => 1..50
  validates_length_of :description, :maximum => 512, :allow_blank => true
  
  def self.statistics(event, current_user)
    source_counts = {}
    
    self.all.each do |source|
      if current_user.type == "User"
        count = event.event_registrations.count(:conditions => ["source_id = ?", source.id]);
      else
        count = event.event_registrations.for_affiliate(current_user.id).count(:conditions => ["source_id = ?", source.id]);
      end

      source_counts[source.name] = count
    end

    return source_counts
  end
end
