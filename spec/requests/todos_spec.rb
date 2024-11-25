require 'rails_helper'

RSpec.describe "Todos API", type: :request do
  let!(:user) { create(:user) } 
  let!(:todo_list) { create(:todo_list, user: user) }
  let!(:todos) { create_list(:todo, 10, todo_list: todo_list) }
  let(:todo) { todos.first }
  let(:auth_headers) { user.create_new_auth_token } 
  let(:invalid_params) { { title: "", status: "" } }

  # GET
  describe "GET /todo_lists/:todo_list_id/todos" do
    it "returns todos when authorized and todo list exists" do
      get "/todo_lists/#{todo_list.id}/todos", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(10)
    end

    it "returns not found when todo list does not exist" do
      get "/todo_lists/99999/todos", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns unauthorized when no auth headers" do
      get "/todo_lists/#{todo_list.id}/todos"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # POST
  describe "POST /todo_lists/:todo_list_id/todos" do
    let(:new_todo_params) { { title: "New Todo", status: "pending" } }
    it "creates a new todo with valid params" do
      post "/todo_lists/#{todo_list.id}/todos", params: { todo: new_todo_params }, headers: auth_headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("New Todo")
    end

    it "returns errors with invalid params" do
      post "/todo_lists/#{todo_list.id}/todos", params: { todo: invalid_params }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Title can't be blank")
    end
  end

  # PUT
  describe "PUT /todo_lists/:todo_list_id/todos/:id" do
    let!(:todo) { create(:todo, todo_list: todo_list) }
    let(:valid_params) { { title: "Updated Title", status: "completed" } }
    
    context "when authorized" do
      it "updates the todo with valid params" do
        put "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: { todo: valid_params }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["title"]).to eq("Updated Title")
        expect(JSON.parse(response.body)["status"]).to eq("completed")
      end
  
      it "returns errors with invalid params" do
        put "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: { todo: invalid_params }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Title can't be blank")
      end
    end
  
    context "when unauthorized" do
      it "returns unauthorized status" do
        put "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: { todo: valid_params }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  #DELETE
  describe "DELETE /todo_lists/:todo_list_id/todos/:id" do
    context "when authorized" do
      it "deletes the todo successfully" do
        expect {delete "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: auth_headers}.to change { todo_list.todos.count }.by(-1)  
        expect(response).to have_http_status(:no_content)
      end

      it "returns unprocessable entity if deletion fails" do
        allow_any_instance_of(Todo).to receive(:destroy).and_return(false)
        delete "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to eq("Could not delete Todo")
      end
    end

    context "when unauthorized" do
      it "returns unauthorized status" do
        delete "/todo_lists/#{todo_list.id}/todos/#{todo.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  #PATCH : TOGGLE
  describe "Toggle status" do
    let!(:todo) { create(:todo, todo_list: todo_list, status: :pending) }

    context "when authorized" do
      it "changes the status" do
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}/toggle_status", headers: auth_headers
        todo.reload
        expect(response).to have_http_status(:ok)
        expect(todo.status).to eq('completed')
        
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}/toggle_status", headers: auth_headers
        todo.reload
        expect(todo.status).to eq('archived')
      end

      it "returns the updated todo in the response" do
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}/toggle_status", headers: auth_headers
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(todo.id)
        expect(json_response['status']).to eq('completed') 
      end
    end

    context "when unauthorized" do
      it "returns unauthorized status" do
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}/toggle_status"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
end
