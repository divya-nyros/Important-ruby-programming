Factory.define :invitation do |i|
  i.code { Factory.next(:unique_code) }
  i.email { Factory.next(:email) }
  i.association :event_type
end