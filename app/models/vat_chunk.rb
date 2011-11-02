class VatChunk < ActiveRecord::Base
  belongs_to :company
  belongs_to :account

  validates :start_date, :presence=> true
  validates :company_id, :presence=> true
  validates :account_id, :presence=> true
  validates_numericality_of :number, :only_integer => true
  validates :number, :uniqueness => { :scope => :company_id, :message => I18n.t("global.number_not_unique") }, :presence => true
  
end
