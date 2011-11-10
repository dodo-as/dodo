class Car < ActiveRecord::Base
  has_many :travel_logs, :order => "odometer ASC"

  belongs_to :company
  attr_protected :company_id, :company

  validates_with DateValidator # ensures from < to

  def to_s
    return name
  end

  def log_include
    [:travel_logs]
  end

end

