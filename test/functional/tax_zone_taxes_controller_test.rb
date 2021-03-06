require 'test_helper'

class TaxZoneTaxesControllerTest < ActionController::TestCase
  setup do
    @tax_zone_taxis = tax_zone_taxes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tax_zone_taxes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tax_zone_taxis" do
    assert_difference('TaxZoneTax.count') do
      post :create, :tax_zone_taxis => @tax_zone_taxis.attributes
    end

    assert_redirected_to tax_zone_taxis_path(assigns(:tax_zone_taxis))
  end

  test "should show tax_zone_taxis" do
    get :show, :id => @tax_zone_taxis.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tax_zone_taxis.to_param
    assert_response :success
  end

  test "should update tax_zone_taxis" do
    put :update, :id => @tax_zone_taxis.to_param, :tax_zone_taxis => @tax_zone_taxis.attributes
    assert_redirected_to tax_zone_taxis_path(assigns(:tax_zone_taxis))
  end

  test "should destroy tax_zone_taxis" do
    assert_difference('TaxZoneTax.count', -1) do
      delete :destroy, :id => @tax_zone_taxis.to_param
    end

    assert_redirected_to tax_zone_taxes_path
  end
end
