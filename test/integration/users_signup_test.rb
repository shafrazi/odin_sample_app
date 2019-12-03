require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "a user should not be created if submitted invalid details" do
    before_count = User.count
    get signup_path
    post users_path, params: { user: { name: "", email: "user@invalid", password: "foobar" } }
    after_count = User.count
    assert_equal before_count, after_count
  end

  test "invalid signup submission should render the signup form again" do
    get signup_path
    post users_path, params: { user: { name: "", email: "user@invalid", password: "foobar" } }
    assert_template :new
  end

  test "invalid signup should display errors" do
    get signup_path
    post users_path, params: { user: { name: "", email: "user@invalid", password: "foobar" } }
    assert_select "#error-explanation", count: 1
  end

  test "valid signup with account activation" do
    get signup_path
    before_count = User.count
    post users_path, params: { user: { name: "test_user", email: "test@testmail.com", password: "foobar" } }
    after_count = User.count
    assert after_count == before_count + 1
    assert_redirected_to root_path
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # try to login before activation
    log_in_as(user)
    assert_not is_logged_in?

    # invalid activation token
    get edit_account_activation_path("invalid activation token", email: user.email)
    assert_not user.reload.activated?
    assert_not is_logged_in?

    # valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "invalid@email.com")
    assert_not user.reload.activated?
    assert_not is_logged_in?

    # valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert is_logged_in?
    assert_not flash.empty?
    assert flash[:success] == "Account activated!"
    assert_redirected_to user_path(user)
    follow_redirect!
    assert_template "users/show"
  end
end
