require 'rails_helper'

RSpec.describe "Collaborators", type: :request do
  let!(:user) { create(:user) } # Owner of the todo list
  let!(:collaborator_user) { create(:user) } # Collaborator user
  let!(:todo_list) { create(:todo_list, user: user) } # Todo list owned by the user
  let!(:auth_headers) { user.create_new_auth_token } # Authentication headers

  describe "GET /users/:user_id/todo_lists/:todo_list_id/collaborators" do
    context "when the user is authorized" do
      let!(:collaborator) { create(:collaborator, user: collaborator_user, todo_list: todo_list) }

      it "returns all collaborators of the todo list" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(1) # Ensure one collaborator is returned
        expect(json[0]["user_id"]).to eq(collaborator_user.id)
      end
    end

    context "when the user is unauthorized" do
      it "returns unauthorized" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the todo list is not found" do
      it "returns not found" do
        get "/users/#{user.id}/todo_lists/999/collaborators", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo list not found")
      end
    end
  end

  describe "POST /users/:user_id/todo_lists/:todo_list_id/collaborators" do
    context "with valid parameters" do
      let(:valid_params) { { collaborator: { user_id: collaborator_user.id } } }
      let!(:collaborator_user) { create(:user) } # Collaborator user

      it "adds a collaborator to the todo list" do
        expect {
          post "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators", 
               params: valid_params, 
               headers: auth_headers
        }.to change { Collaborator.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json["user_id"]).to eq(collaborator_user.id)
        expect(json["todo_list_id"]).to eq(todo_list.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { collaborator: { user_id: nil } } }

      it "does not add a collaborator and returns an error" do
        expect {
          post "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators", 
               params: invalid_params, 
               headers: auth_headers
        }.not_to change { Collaborator.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("User must exist")
      end
    end

    context "when user is already a collaborator" do
      before do
        create(:collaborator, user: collaborator_user, todo_list: todo_list)
      end

      it "does not add a duplicate collaborator and returns an error" do
        post "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators", 
             params: { collaborator: { user_id: collaborator_user.id } }, 
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("User is already a collaborator for this todo list")
      end
    end
  end
  describe "DELETE /users/:user_id/todo_lists/:todo_list_id/collaborators/:id" do
    context "when the user is authorized" do
      let!(:collaborator) { create(:collaborator, user: collaborator_user, todo_list: todo_list) }
  
      it "removes the collaborator from the todo list" do
        expect {
          delete "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators/#{collaborator.id}", headers: auth_headers
        }.to change(Collaborator, :count).by(-1)
  
        expect(response).to have_http_status(:ok)
        expect(json["message"]).to eq("Collaborator removed successfully")
      end
    end
  
    context "when the collaborator is not found" do
      it "returns not found" do
        delete "/users/#{user.id}/todo_lists/#{todo_list.id}/collaborators/999", headers: auth_headers
        
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Collaborator not found")
      end
    end
  
    context "when the todo list is not found" do
      it "returns not found" do
        # Here, we don't need to reference 'collaborator', as we're testing a non-existent todo list.
        delete "/users/#{user.id}/todo_lists/999/collaborators/1", headers: auth_headers
  
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo list not found")
      end
    end
  end
  
end
