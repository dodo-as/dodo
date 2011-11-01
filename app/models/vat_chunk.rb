class VatChunk < ActiveRecord::Base
  belongs_to :company
  belongs_to :account

  validates :start_date, :presence=> true
  validates :company_id, :presence=> true
  validates :account_id, :presence=> true
  validates :number, :uniqueness => { :scope => :company_id, :message => I18n.t("global.number_not_unique") }, :presence => true, :numericality => :only_integer
  
end
