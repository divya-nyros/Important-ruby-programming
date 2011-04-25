Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.sequence :unique_code do |n|
  UUIDTools::UUID.random_create.to_s.gsub(/\W/, '')[0..14]
end