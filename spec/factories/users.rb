FactoryBot.define do
  factory :user do
    name { "Akshita" }
    password { 'Password$123' }
    email { Faker::Internet.email }
  end
end
