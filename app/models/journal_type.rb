class JournalType < ActiveRecord::Base
  has_many :journal_type_counters
  validates :name, :presence=>true, :length => {:minimum=>1, :maximum => 100}

  def to_s
    self.name
  end

  def counter company
    cnt = JournalTypeCounter.where(:company_id => company, :journal_type_id => self)
    
    if cnt.exists?
      cnt=cnt[0]
    else
      cnt = JournalTypeCounter.new :company => company, :journal_type => self, :counter => 1
      cnt.save
    end
    return cnt
  end
  
  def get_next_number company
    cnt = self.counter company
    num = cnt.counter
    while Journal.where(:company_id => company, :journal_type_id => self, :number => num).exists?
      num = num+1
    end
    cnt.counter = num+1
    cnt.save

    return num
    
  end
  
end
