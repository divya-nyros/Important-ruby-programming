Factory.define :work_website, :class => Website do |f|
  f.data "www.yoursitedonerightnow.com"
  f.category "work"
end

Factory.define :personal_website, :class => Website do |f|
  f.data "www.yoursitedonerightnow.com"
  f.category "personal"
end

