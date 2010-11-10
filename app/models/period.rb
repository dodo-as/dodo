class Period < ActiveRecord::Base
  belongs_to :company
  has_many :bills, :autosave => true
  has_many :journals, :autosave => true

  # only useful for random statistics
  has_many :journal_operations, :through => :journals

  cattr_reader :per_page
  @@per_page = 200

  STATUSES = {0 => 'New', 1 => 'Open', 2 => 'Done', 3 => 'Closed'}
  STATUSE_NAMES = {'New' => 0, 'Open' => 1, 'Done' => 2, 'Closed' => 3}

  # if (from_year, to_year) are nil, it will return all periods of the company
  # if (to_year) are nil, it will return all periods until last period of the company
  # if (from_year) are nil, it will return all periods since first period of the company
  # company is required
  def self.get_range(from_year, from_nr, to_year, to_nr, company_id)
    periods = Array.new
    if from_year.blank? && to_year.blank?
      periods.concat(where(['company_id = ?', company_id]))
    else
      unless from_year.blank? 
        periods.concat(where(['company_id = ? and year = ? and nr >= ?', company_id, from_year, from_nr]))    
      end
      if !from_year.blank? && to_year.blank?
        periods.concat(where(['company_id = ? and year > ? ', company_id, from_year]))
      end
      unless to_year.blank?
        periods.concat(where(['company_id = ? and year = ? and nr <= ? ', company_id, to_year, to_nr]))
      end
      if from_year.blank? && !to_year.blank?
        periods.concat(where(['company_id = ? and year < ? ', company_id, to_year]))
      end
      if !from_year.blank? && !to_year.blank?
        periods.concat(where(['company_id = ? and year > ? and year < ? ', company_id, from_year, to_year])) if (to_year - from_year > 1)
      end    
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

  def to_s
    sprintf("%d %.2d", self.year, self.nr)
  end
end
