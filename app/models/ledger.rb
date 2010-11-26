class Ledger < ActiveRecord::Base
  belongs_to :account
  belongs_to :activatable
  belongs_to :unit
  belongs_to :project
  belongs_to :address, :dependent => :destroy
  has_many :paycheck_line_templates , :foreign_key => "employee_id"

  validates :number, :uniqueness => {:scope => [:account_id]}
  accepts_nested_attributes_for :address

  def to_s
    return name
  end

  def tax_rate period
    0.30
  end

  def tax_account period
    Account.where(:number => 5400, :company_id => self.account.company_id).first
  end

  def first_name
    self.name.split(' ')[0]
  end

  def last_name
    self.name.split(' ',2)[1]
  end

end
