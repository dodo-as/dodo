class JournalTypeCounter < ActiveRecord::Base
  belongs_to :journal_type
  belongs_to :company
  
  def to_s
    self.name
  end
  
end
