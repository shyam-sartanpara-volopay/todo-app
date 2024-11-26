# spec/factories/todos.rb
FactoryBot.define do
  factory :todo do
    title { "Sample Todo" }
    status { :pending } # Use a valid status as a symbol
    association :todo_list
  end
end
