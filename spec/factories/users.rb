FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email } # Ensure unique email for each user
    password { "password123" }
    password_confirmation { "password123" }
  end
end