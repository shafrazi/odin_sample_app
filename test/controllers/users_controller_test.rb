require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
    @user = users(:michael)
    @other_user = users(:shafrazi)
    @inactive_user = users(:umesha)
  end

  test "should get new" do
    get signup_path
    assert_response :success
    assert_select "title", "Sign up | #{@base_title}"
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), { params: { user: { name: @user.name, email: @user.email } } }
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect to root path when trying to edit another user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to root_path
  end

  test "should redirect to root path when trying to update another user" do
    log_in_as(@other_user)
    patch user_path(@user), { params: { user: { name: @user.name, email: @user.email } } }
    assert_redirected_to root_path
  end

  test "should redirect to intended page when initially not logged in" do
    get edit_user_path(@user)
    assert_redirected_to login_path
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert session[:forwarding_url].nil?
  end

  test "user index should be shown only to logged in users" do
    get users_path
    assert_redirected_to login_path
  end

  test "should not update the admin attribute of a user" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), { params: { user: { name: "michael", email: "michael@example.com", password: "password", admin: true } } }
    assert_not @other_user.admin?
  end

  test "should destroy a user" do
    before_count = User.count
    log_in_as(@user)
    delete user_path(@other_user)
    after_count = User.count
    assert after_count == before_count - 1
  end

  test "should redirect to root path if a non admin user tries to delete a user" do
    before_count = User.count
    log_in_as(@other_user)
    delete user_path(@user)
    assert_redirected_to root_path
    after_count = User.count
    assert after_count == before_count
  end

  test "should redirect destroy when not logged in" do
    before_count = User.count
    delete user_path(@other_user)
    assert_redirected_to login_path
    after_count = User.count
    assert after_count == before_count
  end

  test "should redirect to root path if accessed a show page of an inactive user" do
    get user_path(@inactive_user)
    assert_redirected_to root_path
    follow_redirect!
    assert_template "static_pages/home"
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_path
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_path
  end
end
