class JournalType < ActiveRecord::Base
  
  validates :name, :presence=>true, :length => {:minimum=>1, :maximum => 100}

  def to_s
    self.name
  end

end
