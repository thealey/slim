require 'test_helper'

class BpsControllerTest < ActionController::TestCase
  setup do
    @bp = bps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bp" do
    assert_difference('Bp.count') do
      post :create, bp: @bp.attributes
    end

    assert_redirected_to bp_path(assigns(:bp))
  end

  test "should show bp" do
    get :show, id: @bp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bp
    assert_response :success
  end

  test "should update bp" do
    put :update, id: @bp, bp: @bp.attributes
    assert_redirected_to bp_path(assigns(:bp))
  end

  test "should destroy bp" do
    assert_difference('Bp.count', -1) do
      delete :destroy, id: @bp
    end

    assert_redirected_to bps_path
  end
end
