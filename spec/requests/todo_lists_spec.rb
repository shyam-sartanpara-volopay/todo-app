require 'rails_helper'

RSpec.describe "TodoLists", type: :request do
  let!(:user) { create(:user) } 
  let!(:todo_lists) { create_list(:todo_list, 10, user: user) } 
  let(:todo_list) { todo_lists.first } 
  let!(:todo_list) { create(:todo_list, user: user, title: "Old Name") }
  let(:auth_headers) { user.create_new_auth_token } 


  def json
    JSON.parse(response.body)
  end

  #GET
  describe "GET /todo_lists" do
    context "user is authorized" do
      it "returns all todo lists" do
        get "/todo_lists",headers:auth_headers
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(11)    
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

      it "returns not found status" do
        get "/todo_lists/0", headers: auth_headers
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq("Todo List not found")
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
