class Project < ActiveRecord::Base
  belongs_to :address, :dependent => :destroy
  belongs_to :company
  accepts_nested_attributes_for :address
  attr_protected :company_id, :company

  validates_with DateValidator # ensures from < to

  def to_s
    return name
  end

  def log_include
    [:address]
  end

end

