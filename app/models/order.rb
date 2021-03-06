class Order < ActiveRecord::Base
  belongs_to :seller, :class_name => 'User'
  belongs_to :customer, :class_name => 'Ledger'
  belongs_to :delivery_address, :class_name => 'Address'
  belongs_to :transport, :class_name => 'Company'
  belongs_to :company, :class_name => 'Company'
  belongs_to :unit
  belongs_to :project
  has_many :order_items

  def discount
    if self.price.nil?
      0
    else
      100.0 * (1.0-self.price / self.order_items.inject(0.0){|sum,item| sum+item.price})
    end
  end

end
