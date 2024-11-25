require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:todos).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "dependent destroy" do
    let!(:todo_list) { create(:todo_list) }
    let!(:todo) { create(:todo, todo_list: todo_list) }

    it "destroys associated todos when the todo list is destroyed" do
      expect { todo_list.destroy }.to change(Todo, :count).by(-1)
    end
  end
end
