require 'test_helper'

class WeeklySaleSetupProductGroupsControllerTest < ActionController::TestCase
  setup do
    @weekly_sale_setup_product_group = weekly_sale_setup_product_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weekly_sale_setup_product_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weekly_sale_setup_product_group" do
    assert_difference('WeeklySaleSetupProductGroup.count') do
      post :create, :weekly_sale_setup_product_group => @weekly_sale_setup_product_group.attributes
    end

    assert_redirected_to weekly_sale_setup_product_group_path(assigns(:weekly_sale_setup_product_group))
  end

  test "should show weekly_sale_setup_product_group" do
    get :show, :id => @weekly_sale_setup_product_group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weekly_sale_setup_product_group.to_param
    assert_response :success
  end

  test "should update weekly_sale_setup_product_group" do
    put :update, :id => @weekly_sale_setup_product_group.to_param, :weekly_sale_setup_product_group => @weekly_sale_setup_product_group.attributes
    assert_redirected_to weekly_sale_setup_product_group_path(assigns(:weekly_sale_setup_product_group))
  end

  test "should destroy weekly_sale_setup_product_group" do
    assert_difference('WeeklySaleSetupProductGroup.count', -1) do
      delete :destroy, :id => @weekly_sale_setup_product_group.to_param
    end

    assert_redirected_to weekly_sale_setup_product_groups_path
  end
end
