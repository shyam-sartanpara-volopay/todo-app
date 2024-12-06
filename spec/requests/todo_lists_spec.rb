require 'rails_helper'

RSpec.describe "TodoLists", type: :request do
  let!(:user) {create(:user)} #Create users 
  let!(:todo_lists) { create_list(:todo_list, 5, user: user) } # Create 5 todo lists for the user
  let(:auth_headers) { user.create_new_auth_token } # Authentication headers

  let!(:collaborator) { create(:user) }
  let(:auth_headers_2){collaborator.create_new_auth_token}
  let!(:todo_list_with_collaborator) { create(:todo_list, user: user) }
  before do
    create(:collaborator, user: collaborator, todo_list: todo_list_with_collaborator)
  end

  describe "GET /users/:user_id/todo_lists" do
    context "user is authorized (owner)" do
      it "returns all todo lists" do
        get "/users/#{user.id}/todo_lists", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(6)
      end  
    end
    context "user is a collaborator on a todo list" do
      it "returns todo lists the user is a collaborator on" do
        get "/users/#{collaborator.id}/todo_lists", headers: auth_headers_2
        expect(response).to have_http_status(:ok)
        expect(json.size).to be > 0  # Ensure there are results (collaborator's todo list should be returned)
      end
    end
    context "unauthorized user (not an owner or collaborator)" do
      let(:other_user) { create(:user) }
      it "returns not found" do
        auth_headers = other_user.create_new_auth_token
        get "/users/#{user.id}/todo_lists", headers: auth_headers
        expect(response).to have_http_status(:not_found)  
      end
    end
  end

  describe "POST /users/:user_id/todo_lists" do
    let(:valid_params) {{todo_list:{title: "new todo list"}}}
    let(:invalid_params) { { todo_list: { title: "" } } }  
    let(:auth_headers) { user.create_new_auth_token } # Authentication headers
    context "with valid parameter" do
      it "creates a new todo list" do
        expect{
          post "/users/#{user.id}/todo_lists", params: valid_params, headers: auth_headers
      }.to change(TodoList, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json["title"]).to eq("new todo list")
      end
    end

    context "with invalid parameters" do
      it "returns invalid entity" do
        expect {
          post "/users/#{user.id}/todo_lists", params: invalid_params, 
          headers: auth_headers}.not_to change(TodoList, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
      end    
    end 
  end
  
  describe "GET /users/:user_id/todo_lists/:id" do
    let(:user) { create(:user) } # Owner of the todo list
    let(:collaborator) { create(:user) } # Collaborator on the todo list
    let!(:todo_list) { create(:todo_list, user: user) } 
    let!(:todo_list_with_collaborator) { create(:todo_list, user: user) }
    let(:auth_headers) { user.create_new_auth_token }
  
    # Associate the collaborator with the `todo_list_with_collaborator`
    before do
      # Ensure a single collaborator association is created
      Collaborator.find_or_create_by(user: collaborator, todo_list: todo_list_with_collaborator)
    end
    
    context "when todo list exists" do
      it "returns the todo list" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(todo_list.id)
        expect(json["title"]).to eq(todo_list.title)
      end
    end
  
    context "when todo list exists (collaborator)" do
      it "returns the todo list" do
        auth_headers = collaborator.create_new_auth_token
        get "/users/#{collaborator.id}/todo_lists/#{todo_list_with_collaborator.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(todo_list_with_collaborator.id)
      end
    end
  
    context "when todo list does not exist" do
      it "returns not found" do
        get "/users/#{user.id}/todo_lists/999", headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo list not found or not accessible")
      end
    end
  end
  
  

  describe "PUT /users/:user_id/todo_lists/:id" do
    let(:user) { create(:user) } # Create a user
    let!(:todo_list) { create(:todo_list, user: user) } 
    let(:valid_params) { { todo_list: { title: "Updated Title" } } }
    let(:invalid_params) { { todo_list: { title: "" } } }
    let(:auth_headers) { user.create_new_auth_token}

    context "with valid parameters" do
      it "updates the todo list" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}", params: valid_params, headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(json["title"]).to eq("Updated Title")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}", params: invalid_params, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
      end
    end
  end

  describe "DELETE /users/:user_id/todo_lists/:id" do
    let(:user) { create(:user) }                # Create a user
    let!(:todo_list) { create(:todo_list, user: user) } 
    let(:auth_headers) { user.create_new_auth_token}

    it "deletes the todo list" do
      expect {
        delete "/users/#{user.id}/todo_lists/#{todo_list.id}", headers: auth_headers
      }.to change(TodoList, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    context "when the todo list does not exist" do
      it "returns not found" do
        delete "/users/#{user.id}/todo_lists/999", headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo list not found or not accessible")
      end
    end
  end


  


end
