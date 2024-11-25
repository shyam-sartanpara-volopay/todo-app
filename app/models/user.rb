class User < ApplicationRecord

        extend Devise::Models
            devise :database_authenticatable, :registerable,
                    :recoverable, :rememberable,:validatable
                    
            include DeviseTokenAuth::Concerns::User
    has_many :todo_lists, dependent: :destroy


  validates :email, presence: true, uniqueness: true
  #validates :password, presence: true, length: { minimum: 6 }
  #validates :name, presence: true
end
