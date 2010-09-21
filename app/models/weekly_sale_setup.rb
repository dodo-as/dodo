class WeeklySaleSetup < ActiveRecord::Base
#  include UserStamp

  belongs_to :company
  belongs_to :unit
  belongs_to :cash_account, :class_name=>'Account'
  belongs_to :period

  has_many :weekly_sale_setup_product_groups, :order=>'display_order', :dependent=>:destroy
  has_many :weekly_sale_setup_liquids, :order=>'display_order', :dependent=>:destroy
  has_many :weekly_sales

  validates :name, :length=>{ :minimum=>1, :maximum=> 100 }, :presence=>true
  validates :journal_type, :length=>{ :minimum=>1, :maximum=> 3 }, :presence=>true
  validates :permanent_cash, :numericality=>true
  validates :unit, :presence=>true
  validates :cash_account, :presence=>true
  validates :company, :presence=>true

  JOURNAL_TYPES = %w(O)
  validates_inclusion_of :journal_type, :in => %w(O)

  validates_uniqueness_of :name, :scope => :company_id

  def description
    self.name + " - " + unit.name
  end

  def to_s
    self.description
  end

  def valid_to_add_weekly_sales

    if self.locked == true && self.valid_from <= Date.today && self.valid_to >= Date.today
      return true    
    end
    return false
  end

  def update_attributes_with_childs(params, weekly_sale_setup_product_groups, weekly_sale_setup_liquids)
    begin 
      transaction do     
        unless weekly_sale_setup_product_groups.nil?
          for_destroy = ""
          weekly_sale_setup_product_groups.each do |key, product_group|               
            if product_group[:new_record] == 'true'
              weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.new()
            else
              for_destroy += key.to_s + ', ' 
              weekly_sale_setup_product_group = WeeklySaleSetupProductGroup.find(product_group[:id])
            end
            weekly_sale_setup_product_group.name = product_group[:name]
            weekly_sale_setup_product_group.display_order = product_group[:display_order]
            weekly_sale_setup_product_group.project_id = product_group[:project_id]
            weekly_sale_setup_product_group.account_id = product_group[:account_id]
            weekly_sale_setup_product_group.company_id = self.company_id
            weekly_sale_setup_product_group.weekly_sale_setup = self
            weekly_sale_setup_product_group.save!
            for_destroy += weekly_sale_setup_product_group.id.to_s + ', '                 
          end
          for_destroy += '0'
          ActiveRecord::Base.connection().execute "delete from weekly_sale_setup_product_groups  where id not in (" + for_destroy + ") and weekly_sale_setup_id = " + self.id.to_s
        end        
        unless weekly_sale_setup_liquids.nil?
          for_destroy = ""
          weekly_sale_setup_liquids.each do |key, liquid|               
            if liquid[:new_record] == 'true'
              weekly_sale_setup_liquid = WeeklySaleSetupLiquid.new()
            else
              for_destroy += key.to_s + ', ' 
              weekly_sale_setup_liquid = WeeklySaleSetupLiquid.find(liquid[:id])
            end
            weekly_sale_setup_liquid.name = liquid[:name]
            weekly_sale_setup_liquid.display_order = liquid[:display_order]
            weekly_sale_setup_liquid.account_id = liquid[:account_id]
            weekly_sale_setup_liquid.company_id = self.company.id
            weekly_sale_setup_liquid.weekly_sale_setup = self
            weekly_sale_setup_liquid.save!
            for_destroy += weekly_sale_setup_liquid.id.to_s + ', '                 
          end
          for_destroy += '0'
          ActiveRecord::Base.connection().execute "delete from weekly_sale_setup_liquids  where id not in (" + for_destroy + ") and weekly_sale_setup_id = " + self.id.to_s
        end
        self.update_attributes(params)
      end                
    end
  rescue Exception=> e  
      logger.error e.backtrace[0,4].join("\n")
      raise e
  end
end
