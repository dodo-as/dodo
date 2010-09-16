require 'test_helper'

class WeeklySaleSetupTest < ActiveSupport::TestCase
  fixtures :weekly_sale_setups
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

 test "test_invalid_with_empty_attributes" do 
    weekly_sale_setup = WeeklySaleSetup.new
    assert !weekly_sale_setup.valid?
    assert weekly_sale_setup.errors.invalid?(:name)
    assert weekly_sale_setup.errors.invalid?(:voucher_type)
  end

 test "test_invalid_min_lenght_attributes" do 
    weekly_sale_setup = WeeklySaleSetup.new
    weekly_sale_setup.name = ""
    assert !weekly_sale_setup.valid?
    assert weekly_sale_setup.errors.invalid?(:name)

  end

 test "test_invalid_max_lenght_attributes" do 
    weekly_sale_setup = WeeklySaleSetup.new
    weekly_sale_setup.name = ""
    assert !weekly_sale_setup.valid?
    assert weekly_sale_setup.errors.invalid?(:name)

  end

 test "test_invalid_numericality_attributes" do 
    weekly_sale_setup = WeeklySaleSetup.find_by_name("Setup for pos 1")
    weekly_sale_setup.permanent_cash = "derfer"
    assert !weekly_sale_setup.valid?
    assert weekly_sale_setup.errors.invalid?(:permanent_cash)

  end

  test "test_invalid_uniqueness_attributes" do 
    weekly_sale_setup = WeeklySaleSetup.create(:name=>)    
    weekly_sale_setup = WeeklySaleSetup.find_by_name("Setup for pos 1")
    assert !weekly_sale_setup.valid?
    assert weekly_sale_setup.errors.invalid?(:permanent_cash)

  end

end
