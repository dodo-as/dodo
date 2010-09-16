class WeeklySaleSetupProductGroup < ActiveRecord::Base
  belongs_to :project
  belongs_to :account
  belongs_to :weekly_sale_setup
  belongs_to :company


  validates :name, :length=>{ :minimum=>1, :maximum=> 100 }, :presence=>true
  validates :weekly_sale_setup, :presence=>true
  validates :account, :presence=>true
  validates :project, :presence=>true
  validates :company, :presence=>true

  validates_uniqueness_of :name, :scope => :weekly_sale_setup_id

  def to_s
    return name
  end

  
end
