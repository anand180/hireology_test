class Organization < ActiveRecord::Base
  has_many :roles
  has_many :users, :through => :roles
  has_many :organizations

  belongs_to :parent_organization, :class => 'Organization'

  def grant_role(role_type, user)
    Role.create!(:role => role_type, :user_id => user.id, :organization_id => id)
  end

  def role_for(user)
    role = roles.find { |r| r.user_id == user.id }
    role ||= parent_organization.role_for(user) if parent_organization

    return role && !role.denied? ? role : nil
  end
end