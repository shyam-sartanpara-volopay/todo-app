# spec/factories/collaborators.rb
FactoryBot.define do
  factory :collaborator do
    user { create(:user) }
    todo_list { create(:todo_list) }
  end
end
