require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "invalid login credentials display flash message" do
    get login_path
    assert_template "sessions/new"
    post login_path, { params: { email: "", password: "" } }
    assert_template "sessions/new"
    assert_not flash.empty?
    assert_select ".alert-danger"
    get root_path
    assert flash.empty?
  end

  test "valid signup" do
    get login_path
    assert_template "sessions/new"
    post login_path, { params: { email: "michael@example.com", password: "password" } }
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", logout_path
  end

  test "logout" do
    get login_path
    post login_path, { params: { email: "michael@example.com", password: "password" } }
    follow_redirect!
    delete logout_path
    follow_redirect!
    assert_not is_logged_in?
    # simulate a user clicking logout in a second window
    delete logout_path
    follow_redirect!
    assert_template "static_pages/home"
    assert_select "a[href=?]", login_path
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: "1")
    assert_not_nil cookies["remember_token"]
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: "0")
    assert_nil cookies["remember_token"]
  end
end
