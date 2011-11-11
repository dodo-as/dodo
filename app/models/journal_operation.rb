class JournalOperation < ActiveRecord::Base
  belongs_to :journal
  belongs_to :account
  belongs_to :ledger
  belongs_to :vat_account
  belongs_to :car
  belongs_to :project
  belongs_to :unit
  belongs_to :closed_operation
  belongs_to :company

  scope :account, lambda {|id| where("account_id = ?",id)}

  def self.car(car)
    if car
      where("car_id = #{car.id}")
    else
      scoped
    end
  end

  def self.unit(unit)
    if unit
      where("unit_id = #{unit.id}")
    else
      scoped
    end
  end

  def self.project(project)
    if project
      where("project_id = #{project.id}")
    else
      scoped
    end
  end

  def debet= (num) 
    if num != "" and num.to_f > 0 then
      self.amount = -num.to_f
    end
  end
  
  def credit= (num)
    if num != "" and num.to_f > 0 then
      self.amount = num.to_f
    end
  end
  
  def debet
    return (self.amount<0.0) ? (-self.amount) : nil
  end

  def credit
    return (self.amount>0.0) ? self.amount : nil
  end
  
end
