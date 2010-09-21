class WeeklySale < ActiveRecord::Base

  belongs_to :weekly_sale_setup
  belongs_to :journal
  belongs_to :period
  belongs_to :company
  belongs_to :closed_by, :class_name=>'User'
  has_many :weekly_sale_shifts, :dependent=>:destroy
  has_many :weekly_sale_shift_product_groups, :through => :weekly_sale_shifts
  has_many :weekly_sale_shift_liquids, :through => :weekly_sale_shifts

  validates :journal_date, :presence=>true
  validates :company, :presence=>true
  validates :weekly_sale_setup, :presence=>true
  validates :period, :presence=>true

  validates_uniqueness_of :week, :scope => [:weekly_sale_setup_id, :from_date, :to_date]

  def create_journal
    if self.weekly_sale_shifts.size > 0 
      if !self.journal
        journal = Journal.new
        self.journal = journal        
      else
        journal = self.journal
        journal.journal_operations.destroy_all
      end
      journal.number = self.journal_number
      journal.journal_date = self.journal_date
      journal.company_id = self.company_id
      journal.period_id = self.period_id
      journal.journal_type = self.weekly_sale_setup.journal_type
      total_product_groups = 0
      setup_product_groups = WeeklySaleShiftProductGroup.find_by_sql(["
        select sum(amount) as amount, 
        weekly_sale_setup_product_groups.id,
        min(weekly_sale_setup_product_groups.account_id) as account_id,
        min(weekly_sale_setup_product_groups.project_id) as project_id 
        from weekly_sale_shift_product_groups, 
        weekly_sale_setup_product_groups, 
        weekly_sale_shifts
        where weekly_sale_shifts.weekly_sale_id = ?
        and weekly_sale_setup_product_groups.id = 
      	  weekly_sale_shift_product_groups.weekly_sale_setup_product_group_id
	      group by weekly_sale_setup_product_groups.id  ", self.id])

      setup_product_groups.each do |setup_product_group|        
        journal_operation = JournalOperation.new
        account = Account.find(setup_product_group.account_id)
        journal_operation.account_id = setup_product_group.id
        journal_operation.amount = setup_product_group.amount          
        if account.vat_account
          journal_operation.vat_account = account.vat_account
          journal_operation.vat = account.vat_account.vat_account_period_from_date(self.journal_date)
        end
        journal_operation.project_id = setup_product_group.project_id
        journal_operation.journal = journal
        journal_operation.save!
        total_product_groups += setup_product_group.amount
      end
      total_liquids = 0
      setup_liquids = WeeklySaleShiftLiquid.find_by_sql(["
        select sum(amount) as amount, 
        weekly_sale_setup_liquids.id,
        min(weekly_sale_setup_liquids.account_id) as account_id 
        from weekly_sale_shift_liquids, 
        weekly_sale_setup_liquids, 
        weekly_sale_shifts
        where weekly_sale_shifts.weekly_sale_id = ?
        and weekly_sale_setup_liquids.id = 
      	  weekly_sale_shift_liquids.weekly_sale_setup_liquid_id
	      group by weekly_sale_setup_liquids.id  ", self.id])
      setup_liquids.each do |setup_liquid|        
        journal_operation = JournalOperation.new
        account = Account.find(setup_liquid.account_id)
        journal_operation.account_id = setup_liquid.id
        journal_operation.amount = setup_liquid.amount * -1        
        if account.vat_account
          journal_operation.vat_account = account.vat_account
          journal_operation.vat = account.vat_account.vat_account_period_from_date(self.journal_date)
        end
        journal_operation.journal = journal
        journal_operation.save!
        total_liquids += setup_liquid.amount
      end          
      cash_amount = total_liquids - total_product_groups
      if cash_amount != 0
        journal_operation = JournalOperation.new
        account = self.weekly_sale_setup.cash_account
        journal_operation.account_id = account.id
        journal_operation.amount = cash_amount        
        if account.vat_account
          journal_operation.vat_account = account.vat_account
          journal_operation.vat = account.vat_account.vat_account_period_from_date(self.journal_date)
        end
        journal_operation.journal = journal
        journal_operation.save!
      end
      journal.save! 
      self.save!      
    end    
  end

  def self.create_weekly_sale(weekly_sale_setup_id, company_id)
    weekly_sale = WeeklySale.new    
    WeeklySale.transaction do
      weekly_sale_setup = WeeklySaleSetup.find(weekly_sale_setup_id)
      weekly_sale.weekly_sale_setup_id = weekly_sale_setup_id
      last_weekly_sale = WeeklySale.where(:weekly_sale_setup_id => weekly_sale.weekly_sale_setup.id).order("to_date desc").first
      last_date = 
      if last_weekly_sale.nil?
        next_date = weekly_sale_setup.valid_from
      else      
        next_date = last_weekly_sale.to_date+1    
      end
      dates = get_next_week_period(next_date)
      weekly_sale.from_date = dates.first
      weekly_sale.to_date = dates.last
      weekly_sale.period = Period.where(:company_id=>company_id, :year=>weekly_sale.from_date.year, :nr=>weekly_sale.from_date.month).first
      weekly_sale.week = weekly_sale.from_date.cweek
      weekly_sale.journal_date = weekly_sale.to_date
      weekly_sale.company_id = company_id
      weekly_sale.save!
      dates.each do |date|
        weekly_sale_shift = WeeklySaleShift.new
        weekly_sale_shift.weekly_sale = weekly_sale
        weekly_sale_shift.date = date   
        weekly_sale.weekly_sale_setup.weekly_sale_setup_product_groups.each do |product_group|
            WeeklySaleShiftProductGroup.create!(
              :weekly_sale_shift=>weekly_sale_shift, 
              :weekly_sale_setup_product_group=>product_group)        
        end
        weekly_sale.weekly_sale_setup.weekly_sale_setup_liquids.each do |liquid|
            WeeklySaleShiftLiquid.create!(
              :weekly_sale_shift=>weekly_sale_shift, 
              :weekly_sale_setup_liquid=>liquid)        
        end
        weekly_sale_shift.save!
      end
    end   
    return weekly_sale
  end

  def self.get_next_week_period(date)
    from_date = Date.new(date.year, date.month, date.day)
    to_date = Date.new(from_date.year, from_date.month, from_date.day) 
    month = date.month
    ready = false
    dates = []
    while ready == false
      if to_date.month !=month
        break        
      elsif to_date.cwday == 7
        ready = true
      end  
      dates << to_date
      to_date += 1

    end    
    
    return dates
  end

  def update_attributes_without_childs(params)
    transaction do         
      self.update_attributes params
      if self.weekly_sale_shifts.any?
        self.weekly_sale_shifts.destroy_all      
      end
    end
  end
  def update_attributes_with_childs(params, weekly_sale_shifts, weekly_sale_shift_product_groups,  weekly_sale_shift_liquids, user)
    
    WeeklySaleShift.transaction do     
      for_destroy = ""
      weekly_sale_shifts.each do |key, shift|               
        if shift[:new_record] == 'true'
          weekly_sale_shift = WeeklySaleShift.new()
        else
          for_destroy += key.to_s + ', ' 
          weekly_sale_shift = WeeklySaleShift.find(shift[:id])
        end
        weekly_sale_shift.z_number = shift[:z_number]
        weekly_sale_shift.z_amount = shift[:z_amount]
        weekly_sale_shift.date = shift[:date]
        weekly_sale_shift.inserted_cash_amount = shift[:inserted_cash_amount]
        weekly_sale_shift.extracted_cash_amount = shift[:extracted_cash_amount]
        weekly_sale_shift.actual_cash_amount = shift[:actual_cash_amount]
        weekly_sale_shift.difference_cash_explanation = shift[:difference_cash_explanation]
        if shift[:closed] == "1"
          weekly_sale_shift.closed_by_id = user.id
          weekly_sale_shift.closed_at = Time.now
          weekly_sale_shift.closed = true  
        end
        if shift[:sign] == "1"
          weekly_sale_shift.sign_by_id = user.id
          weekly_sale_shift.sign_at = Time.now
        end
        weekly_sale_shift.weekly_sale = self
        weekly_sale_shift.save!
        for_destroy += weekly_sale_shift.id.to_s + ', ' 
        weekly_sale_shift_product_groups.each do |key_weekly_sale, products|          
          if key_weekly_sale == key
            products.each do |key_product, product|
              if shift[:new_record] == 'true'
                weekly_sale_shift_product_group = WeeklySaleShiftProductGroup.new()
              else
                weekly_sale_shift_product_group = WeeklySaleShiftProductGroup.find(product[:id])
              end
              weekly_sale_shift_product_group.weekly_sale_setup_product_group_id = product[:product_group_id]
              weekly_sale_shift_product_group.amount = product[:amount]
              if !product[:quantity].nil?
                weekly_sale_shift_product_group.quantity = product[:quantity]
              end
              weekly_sale_shift_product_group.weekly_sale_shift= weekly_sale_shift
              weekly_sale_shift_product_group.save!
            end
          end
        end
        weekly_sale_shift_liquids.each do |key_weekly_sale, liquids|          
          if key_weekly_sale == key
            liquids.each do |key_liquid, liquid|
              if shift[:new_record] == 'true'
                weekly_sale_shift_liquid = WeeklySaleShiftLiquid.new()
              else
                weekly_sale_shift_liquid = WeeklySaleShiftLiquid.find(liquid[:id])
              end
              weekly_sale_shift_liquid.weekly_sale_setup_liquid_id = liquid[:liquid_id]
              weekly_sale_shift_liquid.amount = liquid[:amount]
              weekly_sale_shift_liquid.weekly_sale_shift= weekly_sale_shift
              weekly_sale_shift_liquid.save!
            end
          end
        end
        weekly_sale_shift.save!
      end
     for_destroy += '0'
     ActiveRecord::Base.connection().execute "delete from weekly_sale_shifts  where id not in (" + for_destroy + ") and weekly_sale_id = " + self.id.to_s
     if params[:closed] == '1'
       params["closed_by_id"] = user.id
       params["closed_at"] = Time.now
     end  
     self.update_attributes(params)  
     self.create_journal
    end                
  end

  def sum_a_product_group(product_group_id)
    self.weekly_sale_shift_product_groups.sum("amount", :conditions=>["weekly_sale_setup_product_group_id = ?", product_group_id])
  end
  def sum_a_liquid(liquid_id)
    self.weekly_sale_shift_liquids.sum("amount", :conditions=>["weekly_sale_setup_liquid_id = ?", liquid_id])
  end
  def sum_product_group
    self.weekly_sale_shift_product_groups.sum("amount")
  end
  def sum_received_cash_amount
    self.weekly_sale_shifts.sum("received_cash_amount")
  end
  def sum_total_liquid_amount
    self.weekly_sale_shifts.sum("total_liquid_amount")
  end
  def sum_inserted_cash_amount
    self.weekly_sale_shifts.sum("inserted_cash_amount")
  end
  def sum_extracted_cash_amount
    self.weekly_sale_shifts.sum("extracted_cash_amount")
  end
  def sum_difference_cash_amount
    self.weekly_sale_shifts.sum("difference_cash")
  end
  def sum_actual_cash_amount
    self.weekly_sale_shifts.sum("actual_cash_amount")
  end
  
  def total_cash_net
    self.sum_received_cash_amount + self.sum_inserted_cash_amount - self.sum_extracted_cash_amount + self.private_amount
  end
  def total_inserted_cash_amount
    self.weekly_sale_shifts.sum("inserted_cash_amount")
  end
  def total_extracted_cash_amount
    self.weekly_sale_shifts.sum("extracted_cash_amount")
  end

end
