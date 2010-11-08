require 'test_helper'

class WeeklySalesControllerTest < ActionController::TestCase
  setup do
    @weekly_sale = weekly_sales(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weekly_sales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weekly_sale" do
    assert_difference('WeeklySale.count') do
      post :create, :weekly_sale => @weekly_sale.attributes
    end

    assert_redirected_to weekly_sale_path(assigns(:weekly_sale))
  end

  test "should show weekly_sale" do
    get :show, :id => @weekly_sale.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weekly_sale.to_param
    assert_response :success
  end

  test "should update weekly_sale" do
    put :update, :id => @weekly_sale.to_param, :weekly_sale => @weekly_sale.attributes
    assert_redirected_to weekly_sale_path(assigns(:weekly_sale))
  end

  test "should destroy weekly_sale" do
    assert_difference('WeeklySale.count', -1) do
      delete :destroy, :id => @weekly_sale.to_param
    end

    assert_redirected_to weekly_sales_path
  end
end
