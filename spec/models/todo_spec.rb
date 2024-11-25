require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:user) { create(:user) }
  let(:todo_list) { build(:todo_list, user: user) }

  describe "Associations" do
    it { should belong_to(:todo_list)}
  end

  describe "Validations" do
    it {should validate_presence_of(:title)}
    it 'validates that status is one of the enum values' do
      expect(Todo.statuses.keys).to include('pending', 'completed', 'archived')
    end
  end

  describe "Enums" do
    it "defines valid statuses" do
      expect(Todo.statuses).to eq({ "pending" => 0, "completed" => 1, "archived" => 2 })
    end

    it "has a working enum for statuses" do
      todo = Todo.new(title: "Test Todo")
      todo.status = "pending"
      expect(todo).to be_pending

      todo.status = "completed"
      expect(todo).to be_completed

      todo.status = "archived"
      expect(todo).to be_archived
    end
  end

  describe "toggle status" do
    let!(:todo) { create(:todo, todo_list: todo_list, status: :pending) }
    context "status is pending" do
      it "change to completed" do
        expect(todo.status).to eq('pending')
        todo.toggle_status!
        expect(todo.reload.status).to eq('completed')
      end
    end

    context "status is completed"  do
      before { todo.update(status: :completed) }
      it "change to archived" do
        expect(todo.status).to eq('completed')
        todo.toggle_status!
        expect(todo.reload.status).to eq('archived')
      end
    end

    context "status is archived" do  
      before { todo.update(status: :archived) }
      it "no change" do 
        expect(todo.status).to eq('archived')
        result = todo.toggle_status!
        expect(result).to be_falsey
        expect(todo.reload.status).to eq('archived')
      end
    end
  end
end

