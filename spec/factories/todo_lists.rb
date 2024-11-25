FactoryBot.define do
  factory :todo_list do
    title { Faker::Lorem.sentence }
    user { nil }
  end
end
