class EventRegistration < ActiveRecord::Base
  belongs_to :event
  belongs_to :attendee
  belongs_to :source
  
  validates_uniqueness_of :attendee_id, :scope => :event_id
  
  include AASM
  aasm_column :state # had to specify to avoid NoMethodError 'aasm_state'
  aasm_initial_state :registered
  aasm_state :registered
  aasm_state :confirmed,  :enter => :set_confirmed_at
  aasm_state :checked_in, :enter => :set_checked_in_at
  aasm_state :canceled,   :enter => :set_canceled_at
  
  aasm_event :confirm do
    transitions :to => :confirmed, :from => [ :registered, :checked_in, :canceled ]
  end
  
  aasm_event :check_in do
    transitions :to => :checked_in, :from => [ :registered, :confirmed, :canceled ]
  end
  
  aasm_event :undo_check_in do
    transitions :to => :registered, :from => :checked_in
  end
  
  aasm_event :cancel do
    transitions :to => :canceled, :from => [ :registered, :confirmed ]
  end
  
  # named_scopes
  # ===============================
  self.aasm_states.map(&:name).each do |state|
    # create named scopes
    named_scope state, :conditions => { :state => state.to_s }
  end
  
  named_scope :upcoming, lambda {
    {
      :joins      => [ :event ],
      :conditions => ["events.end_date >= :today", { :today => Date.today }],
      :order      => "events.start_date, events.start_time, events.end_date, events.end_time"
    }
  }

  named_scope :for_affiliate, lambda { |affiliate_id|
    {
      :joins      => [ :attendee ],
      :conditions => ["attendees.affiliate_id = :affiliate_id", { :affiliate_id => affiliate_id }]
    }
  }
  
  named_scope :for_event, lambda { |event|
    {
      :conditions => ["event_id = :event_id", { :event_id => event.id }]
    }
  }
  
  private
    
    def set_timestamp(attribute)
      eval("self.#{attribute.to_s} = Time.now")
    end
    
    def set_confirmed_at
      set_timestamp(:confirmed_at)
    end
    
    def set_canceled_at
      set_timestamp(:canceled_at)
    end
    
    def set_checked_in_at
      set_timestamp(:checked_in_at)
    end
end
