# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Micropost.destroy_all
p 'Microposts destroyed'
User.destroy_all
p 'Users destroyed'

# Create a main sample user
User.create!( name: "Example User",
              email: "example@railstutorial.org",
              password:              "foobar",
              password_confirmation: "foobar",
              admin: true,
              activated: true,
              activated_at: Time.zone.now)

# Generate a bunch of additional user
10.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!( name: name,
                email: email,
                password:              password,
                password_confirmation: password,
                activated: true,
                activated_at: Time.zone.now)
  p "#{n} - #{name} created!"

end
p "Additionals users done!"

# Generate microposts for a subset of users
users = User.order(:created_at).take(50)
# 50.times do
#   content = Faker::Lorem.sentence(word_count: 5)
#   users.each { |user| p user.microposts.create!(content: content) }
# end


10.times do
  p "Testi"
  users.each do |user|
  p "teste"
    
    content = Faker::Lorem.sentence(word_count: 5)
    p user.microposts.create!(content: content)
  end
end

raise

# Create following relationships
users = User.all
user = users.first
following = users[2..40]
followers = users[20..49]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
