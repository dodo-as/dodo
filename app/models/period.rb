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

  #period p1 should be before or equal to p2, returns true also if at least one the periods are nil
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



  # options: from_year, from_nr, to_year, to_nr, company_id 
  # if (from_year, to_year) are nil, it will return all periods of the company from year 1900 to year 3999
  # if (to_year) is nil, it will return all periods until last period of the company until year 3999
  # if (from_year) is nil, it will return all periods since first period of the company since year 1900
  # if (from_nr) is nil, it will return since nr 0
  # if (to_nr) is nil, it will return until nr 9999
  # company is required
  def self.get_range(company_id, options={})

    raise "company is required to get_range" if company_id.blank?

    options.delete_if { |key, value| value.blank? } 
    options[:from_year] ||= 1900    
    options[:from_nr] ||= 0
    options[:to_year] ||= 3999
    options[:to_nr] ||= 9999
    
    periods = []

    if options[:from_year] == options[:to_year]
      periods.concat(where(['company_id = ? and year = ? and nr >= ? and nr <= ? ', company_id, options[:from_year], options[:from_nr], options[:to_nr]]).order("year, nr"))    
    else  
      periods.concat(where(['company_id = ? and year = ? and nr >= ? ', company_id, options[:from_year], options[:from_nr]]).order("year, nr"))    
      periods.concat(where(['company_id = ? and year > ? and year < ? ', company_id, options[:from_year], options[:to_year]]).order("year, nr")) if (options[:to_year] - options[:from_year] > 1)
      periods.concat(where(['company_id = ? and year = ? and nr <= ? ', company_id, options[:to_year], options[:to_nr]]).order("year, nr")) 
    end

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
