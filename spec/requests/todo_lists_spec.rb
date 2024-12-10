require 'rails_helper'

RSpec.describe "TodoLists", type: :request do
  let(:user) { create(:user) }
  let(:collaborator_user) { create(:user) }
  let!(:todo_lists) { create_list(:todo_list, 10, user: user) } 
  let(:todo_list) { todo_lists.first } 
  let!(:collaborator) { create(:collaborator, todo_list: todo_list, user: collaborator_user) }
  let!(:collaborated_list) { create(:todo_list, user: create(:user)) }
  let(:auth_headers) { user.create_new_auth_token } 
  let(:collaborator_headers) { collaborator_user.create_new_auth_token }

  before do
    collaborated_list.collaborators << collaborator
  end

  #GET
  describe "GET /todo_lists" do
    context "user is authorized" do
      it "returns todo lists owned by the user and collaborated on" do
        get "/todo_lists", headers: collaborator_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(1) 
        expect(json.first['id']).to eq(collaborated_list.id)
      end

      it "returns all owned todo lists for the user" do
        get "/todo_lists", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(10)
      end
    end
    
    context "unauthorized user" do
      it "returns invalid users" do
        get "/todo_lists"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  #GET
  describe "GET /todo_lists/:id" do
    context "user is authorized" do
      it "returns the requested todo list" do
        get "/todo_lists/#{todo_list.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(todo_list.id)
        expect(json['title']).to eq(todo_list.title)
      end

      it "returns the collaborated todo list" do
        get "/todo_lists/#{collaborated_list.id}", headers: collaborator_headers
        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(collaborated_list.id)
      end

      it "returns not found status" do
        get "/todo_lists/0", headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to include("Todo List not found") 
      end
    end

    context "unauthorized user" do
      it "returns unauthorized status" do
        get "/todo_lists/#{todo_list.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  #POST
  describe "POST /todo_lists" do
    context "user is authorized" do
      let(:valid_params) { { todo_list: { title: "New Todo List" } } }

      it "creates a new todo list with valid parameters" do
        expect {post "/todo_lists", params: valid_params, headers: auth_headers}.to change(TodoList, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json['title']).to eq("New Todo List") 
      end

      it "returns an error with invalid parameters" do
        invalid_params = { todo_list: { title: "" } }
        expect {post "/todo_lists", params: invalid_params, headers: auth_headers}.not_to change(TodoList, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['title']).to include("can't be blank")
      end
    end

    context "user is unauthorized" do
      let(:valid_params) { { todo_list: { title: "New Todo List" } } }
      it "returns unauthorized status" do
        post "/todo_lists", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  #PUT
  describe "PUT /todo_lists/:id" do
    let!(:todo_list) { create(:todo_list, user: user, title: "Old Name") }
    let(:valid_attributes) { { title: "Updated Name" } }
    let(:invalid_attributes) { { title: "" } }

    context "when authorized" do
      it "updates the todo list with valid attributes" do
        put "/todo_lists/#{todo_list.id}", params: { todo_list: valid_attributes }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(todo_list.reload.title).to eq("Updated Name")
      end

      it "does not update the todo list with invalid attributes" do
        put "/todo_lists/#{todo_list.id}", params: { todo_list: invalid_attributes }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(todo_list.reload.title).to eq("Old Name")
      end
    end

    context "when unauthorized" do
      it "returns unauthorized status" do
        put "/todo_lists/#{todo_list.id}", params: { todo_list: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  
  #DELETE
  describe "DELETE /todo_lists/:id" do
    context "user is authorized" do
      it "deletes the todo list" do
        expect {delete "/todo_lists/#{todo_list.id}", headers: auth_headers}.to change(TodoList, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Todo List deleted successfully')
      end

      it "returns an error if the todo list cannot be deleted" do
        allow_any_instance_of(TodoList).to receive(:destroy).and_return(false)
        delete "/todo_lists/#{todo_list.id}", headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to eq('Unable to delete Todo List')
      end
    end

    context "user is unauthorized" do
      it "returns unauthorized status" do
        delete "/todo_lists/#{todo_list.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
