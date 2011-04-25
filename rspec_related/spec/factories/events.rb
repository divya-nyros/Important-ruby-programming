Factory.define :event do |e|
  e.name "event"
  e.description "Test event"
  e.start_date Date.today + 14
  e.start_time "08:00"
  e.end_date Date.today + 14
  e.end_time "10:00"
  e.state "published"
  e.association :event_type
  e.private false
end

Factory.define :new_event, :parent => :event do |e|
  e.name "Permier League"
  e.description "Test event"
  e.start_date Date.today + 14
  e.start_time "08:00"
  e.end_date Date.today + 14
  e.end_time "10:00"
  e.state "published"
  e.association :event_type
  e.private false
end