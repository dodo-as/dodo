class Assignment < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  belongs_to :company

  validates :role_id, :uniqueness => {:scope => [:user_id, :company_id]}
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :role

end
