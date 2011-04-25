Factory.define :address do |a|
  a.street "123 Main St."
  a.unit ""
  a.city "Davenport"
  a.state "FL"
  a.zip "33837"
  a.category "home"
  # USE after_create { |f| Factory(:address, :addressable => f) }
end