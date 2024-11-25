require 'rails_helper'

RSpec.describe "Todos", type: :request do
  let!(:user) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user) }
  let!(:todos) { create_list(:todo, 5, todo_list: todo_list, status: :pending) }
  let(:auth_headers) { user.create_new_auth_token }

  def json
    JSON.parse(response.body)
  end

  describe "GET /users/:user_id/todo_lists/:todo_list_id/todos" do
    context "when the user is authenticated" do
      it "returns all todos for the todo list" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(5) # Assuming 5 todos were created
      end
    end

    context "when the user is not authenticated" do
      it "returns unauthorized" do
        get "/users/#{user.id}/todo_lists/#{todo_list.id}/todos"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /users/:user_id/todo_lists/:todo_list_id/todos" do
    let(:valid_params) { { todo: { title: "New Todo", status: :pending } } }
    let(:invalid_params) { { todo: { title: "" } } }

    context "with valid parameters" do
      it "creates a new todo" do
        expect {
          post "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: auth_headers
        }.to change(Todo, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json["title"]).to eq("New Todo")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        expect {
          post "/users/#{user.id}/todo_lists/#{todo_list.id}/todos", params: invalid_params, headers: auth_headers
        }.not_to change(Todo, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
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
    let(:todo) { todos.first }
    let(:valid_params) { { todo: { title: "Updated Todo" } } }
    let(:invalid_params) { { todo: { title: "" } } }

    context "with valid parameters" do
      it "updates the todo" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: valid_params, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json["title"]).to eq("Updated Todo")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        put "/users/#{user.id}/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: invalid_params, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to include("Title can't be blank")
      end
    end
  end

  describe "DELETE /users/:user_id/todo_lists/:todo_list_id/todos/:id" do
    let(:todo) { todos.first }

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
  end
end
