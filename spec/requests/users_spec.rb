require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) {create_list(:user,10)} #Create users till 10
  let(:user_id) {users.first.id}
  let(:user1) { create(:user, name: "Jagriti")}

  let(:headers) { user1.create_new_auth_token }
  
  def json
    JSON.parse(response.body)
  end

  describe "GET /users" do
    context "when user exists" do
      it "returns all users" do
        get "/users"
        
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(10)  
      end
    end    
    context "invalid user" do
      it "no user"do
        get "/users"
        expect(response).to have_http_status(:ok)
        expect(json).to eq([])    
      end   
    end
  end

  describe "POST/users" do
    context "new users" do
      it "create a new users" do
        post "/users"
        expect(response).to have_http_status(:ok)
        expect(subject).to    
        
      end
      
      
    end
    
  end
end
