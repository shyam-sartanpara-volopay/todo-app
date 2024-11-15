# spec/factories/todos.rb
FactoryBot.define do
  factory :todo do
    title { "Test Todo" }
    done { false }
  end
end
