class VatAccount < ActiveRecord::Base

  SALES_CODE_RANGE = 100..199
  PURCHASE_CODE_DIFF = 100 # = sales+diff

  has_many :accounts
  belongs_to :company
  belongs_to :target_sales_account, :class_name => 'Account'
  belongs_to :target_purchase_account, :class_name => 'Account'
  has_many :vat_account_periods
  
  # should only be unique in the current company
  # validates :sales_code, :uniqueness => true
  # validates :purchase_code, :uniqueness => true

  def vat_account_period_from_date(date)
    (self.vat_account_periods.find_all do |vat_account_period|
      vat_account_period.valid_from <= date.to_date
     end
    ).min do |a, b|
      a.valid_from <=> b.valid_from
    end
  end

  def as_json options
    super(:include => [:vat_account_periods])
  end
end
