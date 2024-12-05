class CollaboratorPolicy < ApplicationPolicy
def index?
  true
end

def create?
  true
end

def destroy?
  true
end

class Scope < ApplicationPolicy::Scope
end 
end