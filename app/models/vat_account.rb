class VatAccount < ActiveRecord::Base
  has_many :accounts
  belongs_to :company
  belongs_to :target_sales_account, :class_name => 'Account'
  belongs_to :target_purchase_account, :class_name => 'Account'
  has_many :vat_account_periods
  
  validates :sales_code, :uniqueness => true
  validates :purchase_code, :uniqueness => true

  def vat_account_period_from_date(date)
    (self.vat_account_periods.find_all do |vat_account_period|
      vat_account_period.valid_from <= date.to_date
     end
    ).min do |a, b|
      a.valid_from <=> b.valid_from
    end
  end

end
