class WeeklySaleShiftProductGroup < ActiveRecord::Base
  belongs_to :weekly_sale_shift
  belongs_to :weekly_sale_setup_product_group

  def before_validation
    self.amount = 0.0 unless self.amount
    self.quantity = 0.0 unless self.quantity
  end

  def after_save
    #self.weekly_sale_shift.update_total_product_group_amount  
  end
end
