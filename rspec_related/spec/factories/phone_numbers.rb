Factory.define :home_phone, :class => PhoneNumber do |f|
  f.data "123-456-7890"
  f.category "home"
end

Factory.define :mobile_phone, :class => PhoneNumber do |f|
  f.data "890-123-4567"
  f.category "mobile"
end

Factory.define :work_phone, :class => PhoneNumber do |f|
  f.data "321-654-0987"
  f.category "work"
end
