class Organization < ActiveRecord::Base
  has_many :roles
  has_many :users, :through => :roles
  has_many :organizations

  belongs_to :parent_organization, :class => 'Organization'

  before_save :check_tiers

  def grant_role(role_type, user)
    Role.create!(:role => role_type, :user_id => user.id, :organization_id => id)
  end

  def role_for(user)
    role = roles.find { |r| r.user_id == user.id }
    role ||= parent_organization.role_for(user) if parent_organization

    return role && !role.denied? ? role : nil
  end

private
  def check_tiers
    case organization_type
    when 'root'
      check_unique_root
    when 'organization'
      root_is_parent
    when 'child_organization'
      check_child_organization
    end

    validate_parent
  end

  def check_unique_root
    raise "There can be only one root org" unless Organization.find_by_organization_type('root') == nil
  end

  def root_is_parent
    raise "All organizations must have the root organization as their parent" if Organization.find_by_organization_type_and_id('root', parent_organization_id).nil?
  end

  def check_child_organization
    raise "Child organization must have a parent organization" if Organization.find_by_organization_type_and_id('organization', parent_organization_id).nil?
  end

  def validate_parent
    raise "Child organizations cannot have children" if parent_organization && parent_organization.organization_type == 'child_organization'
  end
end