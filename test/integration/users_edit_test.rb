require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test "shows the correct edit user page" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
  end

  test "invalid edits" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path, { params: { user: { name: "", email: "foo@invalid", password: "foo" } } }
    assert_template "users/edit"
    assert_select ".alert-danger"
  end

  test "valid edits" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), { params: { user: { name: name, email: email, password: "" } } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "only logged in users could access edit user" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
    follow_redirect!
    assert_template "sessions/new"
  end
end
