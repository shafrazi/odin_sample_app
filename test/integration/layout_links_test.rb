require "test_helper"

class LayoutLinksTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
  end

  test "should contain all available links when not logged in" do
    get root_path
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", help_path
  end

  test "should contain all available links when logged in" do
    log_in_as(@user)
    get root_path
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
  end
end
