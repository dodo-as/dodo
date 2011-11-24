class TaxZone < ActiveRecord::Base
  has_many :tax_zone_taxes, :class_name => "TaxZoneTax"
  has_many :county_tax_zones
  accepts_nested_attributes_for :county_tax_zones, :allow_destroy => false
  accepts_nested_attributes_for :tax_zone_taxes, :allow_destroy => false
  
  def tax_zone_rate_at_date date
    tr = nil
    if !self.tax_zone_taxes.blank?
        tr = self.tax_zone_taxes.where('"from" <= ? ', date).where('is_visible is true').order('"from" asc').first
    end
    
    if tr != nil
        return tr.tax_rate.to_f
    else
        return nil
    end 
  end
  
end
