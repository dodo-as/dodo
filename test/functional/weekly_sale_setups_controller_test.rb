require 'test_helper'

class WeeklySaleSetupsControllerTest < ActionController::TestCase
  setup do
    @weekly_sale_setup = weekly_sale_setups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weekly_sale_setups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weekly_sale_setup" do
    assert_difference('WeeklySaleSetup.count') do
      post :create, :weekly_sale_setup => @weekly_sale_setup.attributes
    end

    assert_redirected_to weekly_sale_setup_path(assigns(:weekly_sale_setup))
  end

  test "should show weekly_sale_setup" do
    get :show, :id => @weekly_sale_setup.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weekly_sale_setup.to_param
    assert_response :success
  end

  test "should update weekly_sale_setup" do
    put :update, :id => @weekly_sale_setup.to_param, :weekly_sale_setup => @weekly_sale_setup.attributes
    assert_redirected_to weekly_sale_setup_path(assigns(:weekly_sale_setup))
  end

  test "should destroy weekly_sale_setup" do
    assert_difference('WeeklySaleSetup.count', -1) do
      delete :destroy, :id => @weekly_sale_setup.to_param
    end

    assert_redirected_to weekly_sale_setups_path
  end
end
