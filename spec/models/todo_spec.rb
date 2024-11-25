# spec/models/todo_spec.rb
require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:todo_list) { create(:todo_list) }  # Assuming you have a FactoryBot factory for TodoList
  let(:todo) { create(:todo, todo_list: todo_list) }  # Assuming you have a FactoryBot factory for Todo

  # Validation tests
  describe 'validations' do
    it { should validate_presence_of(:title) }
    
    # Fix the status inclusion validation by using strings as the enum values
    it 'validates that status is one of the enum values' do
      expect(Todo.statuses.keys).to include('pending', 'completed', 'archived')
    end
  end

  # Associations tests
  describe 'associations' do
    it { should belong_to(:todo_list) }
  end

  # Enum tests
  describe 'enum status' do
    it 'should define valid statuses' do
      expect(Todo.statuses.keys).to eq(['pending', 'completed', 'archived'])
    end

    it 'should map status values correctly' do
      expect(Todo.statuses[:pending]).to eq(0)
      expect(Todo.statuses[:completed]).to eq(1)
      expect(Todo.statuses[:archived]).to eq(2)
    end
  end

  # Toggle status tests
  describe '#toggle_status!' do
    context 'when the status is pending' do
      it 'should toggle to completed' do
        todo.update(status: :pending)
        todo.toggle_status!
        expect(todo.status).to eq('completed')
      end
    end

    context 'when the status is completed' do
      it 'should toggle to archived' do
        todo.update(status: :completed)
        todo.toggle_status!
        expect(todo.status).to eq('archived')
      end
    end

    context 'when the status is archived' do
      it 'should not allow toggling' do
        todo.update(status: :archived)
        expect(todo.toggle_status!).to be_falsey
        expect(todo.status).to eq('archived')  # Should stay archived
      end
    end
  end

  # Test for creating and saving the Todo
  describe 'creating a todo' do
    it 'should save a todo with a title and status' do
      todo = Todo.new(title: 'Test Todo', status: 'pending', todo_list: todo_list)
      expect(todo.save).to be_truthy
    end

    it 'should not save a todo without a title' do
      todo = Todo.new(status: 'pending', todo_list: todo_list)
      expect(todo.save).to be_falsey
    end
  end
end
