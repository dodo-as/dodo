class Car < ActiveRecord::Base
  has_many :travel_logs, :order => "odometer ASC"

  belongs_to :company
  attr_protected :company_id, :company

  def to_s
    return name
  end

end

