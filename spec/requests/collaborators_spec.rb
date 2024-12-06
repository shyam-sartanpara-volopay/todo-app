require 'rails_helper'

RSpec.describe "Collaborators", type: :request do
  let(:user) { create(:user) }           
  let(:todo_list) { create(:todo_list, user: user) } 
  let!(:collaborator) { create(:user) }     
  let!(:collaborator_todo_list) { create(:collaborator, todo_list: todo_list, user: collaborator) }
  let(:auth_headers) { user.create_new_auth_token } 
  let(:valid_params) { { collaborator: { user_id: collaborator.id } } }
  let(:invalid_params) { { collaborator: { user_id: nil } } }


  describe "GET /index" do
    context "user is authorized and todolist exist" do
      it "returns collaboration " do
        get "/todo_lists/#{todo_list.id}/collaborators", headers:auth_headers
        expect(response).to have_http_status(:ok)
        expect(json).to include(a_hash_including('id' => collaborator_todo_list.id, 'user_id' => collaborator.id))
      end  
    end
    context "unauthorized user and todolist not exist" do
      it "returns an error when the todo list is not found" do
        get "/todo_lists/invalid_id/collaborators", headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Todo list not found or not accessible')
      end

      it "returns an error when the user is unauthorized" do
        get "/todo_lists/#{todo_list.id}/collaborators"
        expect(response).to have_http_status(:unauthorized)
        expect(json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe "POST /todo_lists" do
    context "user is authorized" do
      it "creates a new collaborator with valid parameters" do
        new_collaborator = create(:user) 
        valid_params = { collaborator: { user_id: new_collaborator.id } }
        expect {
          post "/todo_lists/#{todo_list.id}/collaborators", params: valid_params, headers: auth_headers
        }.to change(Collaborator, :count).by(1)
  
        expect(response).to have_http_status(:created)
        expect(json['user_id']).to eq(new_collaborator.id)
      end

      it "does not create a new collaborator and returns errors" do
        expect {
          post "/todo_lists/#{todo_list.id}/collaborators", params: invalid_params, headers: auth_headers
        }.not_to change(Collaborator, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key('user')
        expect(json['user']).to include('must exist') 
      end
    end

    context "user is unauthorized" do
      it "returns an unauthorized status" do
        post "/todo_lists/#{todo_list.id}/collaborators", params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe "Delete /todo_lists/:todo_list_id/collaborators/:id" do
    context "user is authorized" do
      it "removes the collaborator is done" do
        expect {
          delete "/todo_lists/#{todo_list.id}/collaborators/#{collaborator_todo_list.id}", headers: auth_headers
        }.to change(Collaborator, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Collaborator removed successfully')
      end

      it "returns an error message" do
        non_existent_id = 9999  
        delete "/todo_lists/#{todo_list.id}/collaborators/#{non_existent_id}", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Collaborator not found')
      end
    end

    context "user is unauthorized" do
      it "returns an unauthorized status" do
        delete "/todo_lists/#{todo_list.id}/collaborators/#{collaborator_todo_list.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end

  end


end
