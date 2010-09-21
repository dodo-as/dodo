class WeeklySaleShift < ActiveRecord::Base

  belongs_to :weekly_sale
  belongs_to :closed_by, :class_name=>'User'
  belongs_to :sign_by, :class_name=>'User'
  validates :weekly_sale, :presence=>true

  has_many :weekly_sale_shift_product_groups, :dependent=>:destroy
  has_many :weekly_sale_shift_liquids, :dependent=>:destroy

  def after_initialize
    self.date = Date.today unless self.date
    self.z_amount = 0.0 unless self.z_amount
  end

  def before_save
    self.total_product_group_amount = self.weekly_sale_shift_product_groups.sum("amount")    
    self.total_liquid_amount = self.weekly_sale_shift_liquids.sum("amount")
    self.received_cash_amount = self.total_product_group_amount - self.total_liquid_amount
    self.difference_cash = self.actual_cash_amount - (self.received_cash_amount + self.inserted_cash_amount - self.extracted_cash_amount)     
  end
  
end
