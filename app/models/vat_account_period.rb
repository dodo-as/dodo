class VatAccountPeriod < ActiveRecord::Base
  belongs_to :vat_account

  accepts_nested_attributes_for :vat_account, :allow_destroy => true

end
