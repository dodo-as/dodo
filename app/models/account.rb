class Account < ActiveRecord::Base
  has_many :ledgers, :dependent => :destroy, :order => "lower(name)"
  has_many :products
  belongs_to :company
  belongs_to :activatable
  belongs_to :vat_account

  scope :company, lambda {|company_id| where("company_id = ?", company_id)}
  scope :is_result_account, where(:is_result_account => true)
  scope :is_balance_account, where(:is_result_account => false)
  scope :has_ledger, where(:has_ledger => true)

  def is_result_account?
    self.is_result_account
  end

  def vat_description
    if self.vat_account
      if self.vat_account.target_account
        return self.vat_account.target_account.name
      end
      return "has vat, but invalid"
    end
    return "none"
  end

  def description
    sprintf('%.4d', self.number) + " " + self.name
  end

  def to_s
    return description
  end
  
end
