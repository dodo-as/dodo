class County < ActiveRecord::Base
  has_many :county_tax_zones
  has_many :county_ledgers
  accepts_nested_attributes_for :county_tax_zones, :allow_destroy => false
  accepts_nested_attributes_for :county_ledgers, :allow_destroy => false
  validates_presence_of :name, :allow_nil => false
  
  def tax_zone_at_date date
    if !self.county_tax_zones.blank?
        tz = self.county_tax_zones.where('"from" <= ? ', date).where('is_visible is true').order('"from" asc').last
        if tz != nil
            return tz.tax_zone
        else
            return nil
        end
    else
        []
    end
  end
  
end
