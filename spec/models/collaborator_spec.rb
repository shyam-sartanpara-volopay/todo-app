require 'rails_helper'

RSpec.describe Collaborator, type: :model do
  let(:user) { create(:user) }               
  let(:todo_list) { create(:todo_list, user: user) } 
  let(:another_todo_list) { create(:todo_list, user: user) }


  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:todo_list) }
  end
  
  describe "validations" do
    context "when user is added as a collaborator" do
      it "is valid with unique user_id for a specific todo list" do
        collaborator = Collaborator.new(user: user, todo_list: todo_list)
        expect(collaborator).to be_valid
      end

      it "is invalid if the same user is added twice to the same todo list" do
        Collaborator.create(user: user, todo_list: todo_list)
        duplicate_collaborator = Collaborator.new(user: user, todo_list: todo_list)

        expect(duplicate_collaborator).to_not be_valid
        expect(duplicate_collaborator.errors[:user_id]).to include("is already a collaborator for this todo list")
      end

      it "is valid for the same user to be added to different todo lists" do
        Collaborator.create(user: user, todo_list: todo_list)
        collaborator_for_another_list = Collaborator.new(user: user, todo_list: another_todo_list)

        expect(collaborator_for_another_list).to be_valid
      end
    end
  end
end
