Factory.define :attendee do |a|
  a.first_name 'Will'
  a.last_name 'Attend'
  a.email { Factory.next(:email) }
end

Factory.define :guest, :parent => :attendee do |a|
  a.first_name 'Guest'
  a.last_name 'Guest'
  a.email { Factory.next(:email) }
end