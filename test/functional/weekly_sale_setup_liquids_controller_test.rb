require 'test_helper'

class WeeklySaleSetupLiquidsControllerTest < ActionController::TestCase
  setup do
    @weekly_sale_setup_liquid = weekly_sale_setup_liquids(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weekly_sale_setup_liquids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weekly_sale_setup_liquid" do
    assert_difference('WeeklySaleSetupLiquid.count') do
      post :create, :weekly_sale_setup_liquid => @weekly_sale_setup_liquid.attributes
    end

    assert_redirected_to weekly_sale_setup_liquid_path(assigns(:weekly_sale_setup_liquid))
  end

  test "should show weekly_sale_setup_liquid" do
    get :show, :id => @weekly_sale_setup_liquid.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weekly_sale_setup_liquid.to_param
    assert_response :success
  end

  test "should update weekly_sale_setup_liquid" do
    put :update, :id => @weekly_sale_setup_liquid.to_param, :weekly_sale_setup_liquid => @weekly_sale_setup_liquid.attributes
    assert_redirected_to weekly_sale_setup_liquid_path(assigns(:weekly_sale_setup_liquid))
  end

  test "should destroy weekly_sale_setup_liquid" do
    assert_difference('WeeklySaleSetupLiquid.count', -1) do
      delete :destroy, :id => @weekly_sale_setup_liquid.to_param
    end

    assert_redirected_to weekly_sale_setup_liquids_path
  end
end
