class Car < ActiveRecord::Base
  belongs_to :company
  attr_protected :company_id, :company

  def to_s
    return name
  end

end

