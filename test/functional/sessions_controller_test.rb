require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Person.stubs(:authenticate).returns(nil)
    post :create
    assert_template 'new'
    assert_nil session['person_id']
  end

  def test_create_valid
    Person.stubs(:authenticate).returns(Person.first)
    post :create
    assert_redirected_to root_url
    assert_equal Person.first.id, session['person_id']
  end
end
