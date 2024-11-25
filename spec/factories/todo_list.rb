FactoryBot.define do
  factory :todo_list do
    title { "Sample Todo List" } # Use `title` instead of `name`
    association :user # Ensure the todo_list is linked to a user
  end
end
