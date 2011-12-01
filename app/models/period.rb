class Period < ActiveRecord::Base
  belongs_to :company
  has_many :bills, :autosave => true
  has_many :journals, :autosave => true

  # only useful for random statistics
  has_many :journal_operations, :through => :journals

  cattr_reader :per_page
  @@per_page = 200

  STATUSES = {0 => 'New', 1 => 'Open', 2 => 'Done', 3 => 'Locked', 4 => 'Closed'}
  STATUSE_NAMES = {'New' => 0, 'Open' => 1, 'Done' => 2, 'Locked' => 3, 'Closed' => 4}

  scope :company, lambda {|company_id| where("company_id = ?", company_id)}

  #determine company starting period
  def self.company_start_period(comp_id)
    return Period.company(comp_id).order('year,nr').first
  end

  #determine company last period
  def self.company_last_period(comp_id)
    return Period.company(comp_id).order('year,nr').last
  end

  #period p1 should be before or equal to p2, returns true also if at least one the periods are nil
  #returns false only if p1>p2
  def self.ordred_periods?(p1,p2)

    if p1.blank? or p2.blank?
        true
    elsif p1.year < p2.year
        true
    elsif p1.year == p2.year && p1.nr <= p2.nr
        true
    else
      false
    end

  end

  # determine periods range from two boundries periods given
  #p1 is from period, p2 is to period
  #p2 is included in range if p2_included boolean value is set to true, if false p2 is not included in range
  # ! Make sure p1 and p2 are valid periods boundries before calling the method
  def self.get_range(company_id,p1, p2, p2_included)
    periods = []
    periods = Period.company(company_id).where("year > ? or year = ? and nr >= ?",p1.year,p1.year, p1.nr).where("year < ? or year = ? and nr <= ?", p2.year, p2.year, p2.nr ).order('year,nr')
    periods.pop unless p2_included  #remove p2 boundry from periods
    return periods
  end

  # determine the last year periods range from two boundries periods given
  #p1 is from period, p2 is to period
  #p2 is included in range if p2_included boolean value is set to true, if false p2 is not included in range
  # ! Make sure p1 and p2 are valid periods boundries before calling the method
  def self.get_range_of_last_year(company_id,p1,p2,p2_included)
    periods = []
    periods = Period.company(company_id).where("year > ? or year = ? and nr >= ?",p1.year - 1,p1.year - 1, p1.nr).where("year < ? or year = ? and nr <= ?", p2.year - 1, p2.year - 1, p2.nr ).order('year,nr')
    periods.pop unless p2_included#remove p2 of last year boundry from periods
    return periods
  end

  def status_name
    STATUSES[self.status]
  end

  def open?
    permitted_to? :update, self
  end

  def create_next
    year = self.year
    nr = self.nr + 1
    if nr > 13
      nr = 1
      year = year + 1
    end
    return Period.new :company => self.company, :year => year, :nr => nr, :status => Period::STATUSE_NAMES['New']
  end

  def open_bills
    return self.bills.find_all { |bill| bill.open? }
  end

  def move_open_bills(new_period)
    self.open_bills.each do |bill|
      new_period.bills.push(bill)
      self.bills.delete(bill)
    end
  end

  def status_elevation_requires_closing_bills?
    return self.status >= Period::STATUSE_NAMES['Open'] && self.open_bills.count > 0
  end

  def elevate_status
    if self.status_elevation_requires_closing_bills?
      raise Exception.new "Can not close period with open bills"
    end
    self.status += 1
  end
  
  def append_only?
    return self.status == STATUSE_NAMES['Locked']
  end

  def to_s
    sprintf("%d %.2d", self.year, self.nr)
  end
end
