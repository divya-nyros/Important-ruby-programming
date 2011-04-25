Factory.define :event_type do |f|
  f.name "3D"
  f.description "3 Day Event"
  f.registration_url "http://3dayevent.com/registration"
  f.email "notify@3dayevent.com"
end

Factory.define :wm, :parent => :event_type do |f|
  f.name "WM"
  f.description "Weekly meeting"
  f.registration_url "http://wm.com/registration"
  f.email "notify@3dayevent.com"
end