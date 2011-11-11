class VatAccountPeriod < ActiveRecord::Base

  belongs_to :vat_account

  accepts_nested_attributes_for :vat_account, :allow_destroy => true

  # let's not do this since different companies might use the same date
  # validates :valid_from, :uniqueness => true
  validates :percentage, :presence => true # may not be true

end
