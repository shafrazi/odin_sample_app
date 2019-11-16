require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
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

  test "valid signup should create a new user and redirect to show user page" do
    get signup_path
    before_count = User.count
    post users_path, params: { user: { name: "test_user", email: "test@testmail.com", password: "foobar" } }
    after_count = User.count
    assert after_count == before_count + 1
    follow_redirect!
    assert_template "users/show"
    assert_select ".alert-success"
  end
end
