class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  def denied?
    return role_type == 'denied'
  end
end