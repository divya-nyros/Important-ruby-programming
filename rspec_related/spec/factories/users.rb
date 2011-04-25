Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.first_name 'AGI'
  u.last_name 'User'
  u.password 'password'
  u.password_confirmation 'password'
end

Factory.define :admin, :parent => :user do |u|
  u.first_name 'AGI'
  u.last_name 'Admin'
  u.password 'password'
  u.password_confirmation 'password'
end

Factory.define :affiliate do |u|
  u.email { Factory.next(:email) }
  u.first_name 'Divya'
  u.last_name 'Dasari'
  u.password 'password'
  u.password_confirmation 'password'  
end