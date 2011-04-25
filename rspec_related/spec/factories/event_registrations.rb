Factory.define :event_registration do |e|
  e.association :event
  e.association :attendee
  e.state "registered"
  e.guest 
end

Factory.define :new_event_registration, :parent => :event_registration do |e|
  e.association :event
  e.association :attendee
  e.state "registered"
  e.guest_of
end