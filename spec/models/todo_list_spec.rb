require 'rails_helper'

RSpec.describe TodoList, type: :model do
  let(:user) { create(:user) }
  let(:todo_list) { build(:todo_list, user: user) }

  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:todos).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:user_id) }
  end

  describe "Callbacks" do
    it "destroys associated todos when deleted" do
      todo_list = create(:todo_list, user: user)
      create_list(:todo, 5, todo_list: todo_list)

      expect { todo_list.destroy }.to change { Todo.count }.by(-5)
    end
  end
end

