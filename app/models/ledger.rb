class Ledger < ActiveRecord::Base
  belongs_to :account
  belongs_to :activatable
  belongs_to :unit
  belongs_to :project
  belongs_to :address, :dependent => :destroy
  has_many :paycheck_line_templates , :foreign_key => "employee_id"  
  has_many :county_ledgers
  #~ accepts_nested_attributes_for :county_ledgers, :allow_destroy => false
  validates :number, :uniqueness => {:scope => [:account_id]},  :presence => true

  validates :name, :presence => true
  accepts_nested_attributes_for :address
  #~ validates :date_of_birth, :presence => true
  #~ validates :id_number, :presence => true
  
  validates :mobile_number, :presence => true
  #~ validates :email, :presence => true
  #~ validates :ledger_bank_number, :presence => true, :if => Proc.new { |a| a.foreign_bank_number.blank? }
  #~ validates :foreign_bank_number, :presence => true, :if => Proc.new { |a| a.ledger_bank_number.blank? }
  validates :credit_days, :presence => true
  validates :procenttrekk, :presence => true, :if => Proc.new { |a| a.tabelltrekk.blank? }
  validates :tabelltrekk, :presence => true, :if => Proc.new { |a| a.procenttrekk.blank? }

  validates_with LedgerValidator  # This is custom validator found in /lib/validators/

  def self.get_ledgers_of_current_company
    ledgers = []
    Account.with_permissions_to(:index).has_ledger.order("number").each do |a|
      ledgers += Ledger.ledgers_sorted_with_number(a.id)
    end
    return ledgers
  end

  #get ledger ids from range for filtering
  def self.get_ids_of_range(from_ledger, to_ledger)
    ledgers = Ledger.get_ledgers_of_current_company.collect {|p| p.id }
    if from_ledger.blank? and to_ledger.blank?
       ledgers = []
    elsif from_ledger.blank? and !to_ledger.blank?
      ledgers = ledgers[0,(ledgers.index(to_ledger.id) + 1)]
    elsif !from_ledger.blank? and to_ledger.blank?
      ledgers =  ledgers[ledgers.index(from_ledger.id),(ledgers.length - ledgers.index(from_ledger.id) )]
    else
      ledgers = ledgers[ledgers.index(from_ledger.id),(ledgers.index(to_ledger.id)- ledgers.index(from_ledger.id) + 1)]
    end
    return ledgers
  end

  def self.ledgers_sorted_with_number(account_id)
    Ledger.where(:account_id => account_id).order("number")
  end

  def to_s_with_account
    return account.number.to_s + " " + account.name.to_s + " " + number.to_s + " " + name
  end

  def to_s_with_number
    return number.to_s + " "  + name
  end

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
  
  
    def county_at_date date
        if !self.county_ledgers.blank?
            c = self.county_ledgers.order('"from" asc').where('"from" <= ? ', date).last
            if c != nil
                return c.county
            else
                return nil
            end
        else
            []
        end
    end
     

end
