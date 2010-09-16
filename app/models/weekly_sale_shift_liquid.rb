class WeeklySaleShiftLiquid < ActiveRecord::Base
  belongs_to :weekly_sale_shift
  belongs_to :weekly_sale_setup_liquid

  def after_save
    #self.weekly_sale_shift.update_total_liquid_amount  
  end

end
