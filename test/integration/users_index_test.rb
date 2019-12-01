require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
    @other_user = users(:shafrazi)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@user)
    assert @user.admin?
    get users_path
    assert_template "users/index"
    assert_select "ul.pagination"
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      if user != @user
        assert_select "a[href=?]", user_path(user), text: "Delete"
      end
    end
  end

  test "index as non admin" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    get users_path
    assert_template "users/index"
    assert_select "ul.pagination"
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      assert_select "a[href=?]", user_path(user), text: "Delete", count: 0
    end
  end
end
