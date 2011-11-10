require 'test_helper'

class AdminLogsControllerTest < ActionController::TestCase
  setup do
    @admin_log = admin_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_log" do
    assert_difference('AdminLog.count') do
      post :create, :admin_log => @admin_log.attributes
    end

    assert_redirected_to admin_log_path(assigns(:admin_log))
  end

  test "should show admin_log" do
    get :show, :id => @admin_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @admin_log.to_param
    assert_response :success
  end

  test "should update admin_log" do
    put :update, :id => @admin_log.to_param, :admin_log => @admin_log.attributes
    assert_redirected_to admin_log_path(assigns(:admin_log))
  end

  test "should destroy admin_log" do
    assert_difference('AdminLog.count', -1) do
      delete :destroy, :id => @admin_log.to_param
    end

    assert_redirected_to admin_logs_path
  end
end
