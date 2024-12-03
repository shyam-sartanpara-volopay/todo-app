require 'rails_helper'

RSpec.describe "Todos", type: :request do
  let!(:user) { create(:user) }
  let!(:collaborator) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user) }
  let!(:todos) { create_list(:todo, 5, todo_list: todo_list, status: :pending) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:auth_headers_2) { collaborator.create_new_auth_token }
  
  # Adding a collaborator to the todo list
  before do
    create(:collaborator, user: collaborator, todo_list: todo_list)
  end

  describe "GET /users/:user_id/todo_lists/:todo_list_id/todos" do
    context "when the user is the owner and authenticated" do
      it "returns all todos for the todo list" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(5) # Assuming 5 todos were created
      end
    end

    context "when the user is a collaborator and authenticated" do
      it "returns all todos for the todo list" do
        get "/users/#{collaborator.id}/todo_lists/#{todo_list.id}/todos", headers: auth_headers_2
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(5)
      end
    end

    context "when the user is not authenticated" do
      it "returns unauthorized" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/todos"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the user is authenticated but not authorized" do
      let!(:other_user) { create(:user) }

      it "returns forbidden if the user is not a collaborator or the owner" do
        get "/users/#{other_user.id}/todo_lists/#{todo_list.id}/todos", headers: other_user.create_new_auth_token
        expect(response).to have_http_status(:not_found)
      end
    end
  end 

  describe "POST /users/:user_id/todo_lists/:todo_list_id/todos" do
    let(:valid_params) { { todo: { title: "New Todo", status: "pending" } } }
    let(:invalid_params) { { todo: { title: "" } } }
    create(:collaborator, user: collaborator, todo_list: todo_list)
  
    context "when the collaborator is authenticated" do
      it "creates a new todo for the todo list" do
        expect {
          post "/users/#{collaborator.id}/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: auth_headers_2
        }.to change(Todo, :count)
  
        expect(response).to have_http_status(:created)
        expect(json["title"]).to eq("New Todo")
        expect(json["status"]).to eq("pending")
      end
    end
  
    context "when the collaborator is not authorized" do
      let!(:other_user) { create(:user) }
      let(:unauthorized_headers) { other_user.create_new_auth_token }
  
      it "returns forbidden if the user is not a collaborator or the owner" do
        post "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: unauthorized_headers
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo List not found")
      end
    end
  
    context "with invalid parameters" do
      it "returns unprocessable entity" do
        expect {
          post "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", params: invalid_params, headers: auth_headers_2
        }.not_to change(Todo, :count)
  
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to include("Todo not found")
      end
    end
  end
  
  
  describe "PATCH /users/:user_id/todo_lists/:todo_list_id/todos/:id" do
    let(:todo) { todos.first }
    let(:valid_params) { { todo: { title: "Updated Todo" } } }
    let(:invalid_params) { { todo: { title: "" } } }
  
    context "with valid parameters" do
      it "updates the todo" do
        patch "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: valid_params, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json["title"]).to eq("Updated Todo")
      end
    end
  
    context "with invalid parameters" do
      it "returns unprocessable entity" do
        patch "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: invalid_params, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
      end
    end
  end
  
  describe "PUT /users/:user_id/todo_lists/:todo_list_id/todos/:id" do
    before do
      # Mock Pundit's `authorize` method to test the policy logic
      allow(controller).to receive(:authorize).with(todo).and_return(true)
    end
  
    context "with valid parameters" do
      it "updates the todo" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: valid_params, headers: auth_headers
  
        expect(response).to have_http_status(:ok)
        expect(json["title"]).to eq("Updated Todo")
        expect(todo.reload.title).to eq("Updated Todo")
      end
    end
  
    context "with invalid parameters" do
      it "returns unprocessable entity" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: invalid_params, headers: auth_headers
  
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
      end
    end
  
    context "when the user is not authorized" do
      it "raises an authorization error" do
        allow(controller).to receive(:authorize).with(todo).and_raise(Pundit::NotAuthorizedError)
  
        put "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: valid_params, headers: auth_headers
  
        expect(response).to have_http_status(:forbidden)
        expect(json["error"]).to include("You are not authorized to perform this action")
      end
    end
  end

  describe "DELETE /users/:user_id/todo_lists/:todo_list_id/todos/:id" do
    before do
      # Mock Pundit's `authorize` method to test the policy logic
      allow(controller).to receive(:authorize).with(todo).and_return(true)
    end
  
    it "deletes the todo" do
      expect {
        delete "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: auth_headers
      }.to change(Todo, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  
    context "when the todo does not exist" do
      it "returns not found" do
        delete "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/999", headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("Todo not found")
      end
    end
  
    context "when the user is not authorized" do
      it "returns forbidden" do
        allow(controller).to receive(:authorize).with(todo).and_raise(Pundit::NotAuthorizedError)
        
        delete "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: auth_headers
        
        expect(response).to have_http_status(:forbidden)
        expect(json["error"]).to include("You are not authorized to perform this action")
      end
    end
end
end