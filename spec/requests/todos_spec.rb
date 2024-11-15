require 'rails_helper'

RSpec.describe "Todos API", type: :request do
  let!(:todos) { create_list(:todo, 10) }
  let(:todo_id) { todos.first.id }

  describe "GET /todos" do
    before { get "/todos" }

    it "returns todos" do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /todos" do
    let(:valid_attributes) { { title: "Learn Rails", done: false }.to_json }

    context "when the request is valid" do
      before { post "/todos", params: valid_attributes, headers: { 'CONTENT_TYPE' => 'application/json' } }

      it "creates a todo" do
        expect(JSON.parse(response.body)['title']).to eq('Learn Rails')
        #expect(json["title"]).to eq("Learn Rails")
      end

      it "returns status code 201" do
        expect(response).to have_http_status(201)
      end
    end
  end

  describe "PUT /todos/:id" do
    let(:valid_attributes) { { done: true }.to_json }

    context "when the record exists" do
      before { put "/todos/#{todo_id}", params: valid_attributes, headers: { 'CONTENT_TYPE' => 'application/json' } }

      it "updates the record" do
        expect(json["done"]).to eq(true)
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end

    context "when the record does not exist" do
      let(:todo_id) { 100 }

      before { put "/todos/#{todo_id}", params: valid_attributes, headers: { 'CONTENT_TYPE' => 'application/json' } }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        expect(response.body).to match(/Todo not found/)
      end
    end
  end

  describe "DELETE /todos/:id" do
    context "when the record exists" do
      before { delete "/todos/#{todo_id}" }

      it "returns status code 204" do
        expect(response).to have_http_status(204)
      end
    end

    context "when the record does not exist" do
      let(:todo_id) { 100 }

      before { delete "/todos/#{todo_id}" }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        expect(response.body).to match(/Todo not found/)
      end
    end
  end
end