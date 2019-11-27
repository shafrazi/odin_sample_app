require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
    @user2 = User.new(name: "foo", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should be unique" do
    @user2.email = @user2.email.upcase
    @user.save
    assert_not @user2.valid?
  end

  test "name length should be below 50" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid email addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_USER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |email|
      @user.email = email
      assert @user.valid?, "#{email.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example foo@bar_b foo@bar+baz.com]
    invalid_addresses.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email.inspect} should be invalid"
    end
  end

  test "email should be downcase after saved" do
    user3 = @user.dup
    user3.email = "FOO@FOOBAR.COM"
    user3.save
    assert user3.email == "foo@foobar.com"
  end

  test "password should not be blank" do
    @user.password = " " * 6
    assert_not @user.valid?
  end

  test "password minimum length should be 6" do
    @user.password = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil remember_digest" do
    assert_not @user.authenticated?("")
  end
end
