require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @micropost = microposts(:first_post)
  end

  test "microposts should not be created if user is not logged in" do
    before_count = Micropost.count
    post microposts_path, { params: { micropost: { content: "test content" } } }
    after_count = Micropost.count
    assert_redirected_to login_path
    assert_equal before_count, after_count
  end

  test "should redirect destroy when not logged in" do
    before_count = Micropost.count
    delete micropost_path(@micropost)
    after_count = Micropost.count
    assert_redirected_to login_path
    assert_equal before_count, after_count
  end

  test "should redirect destroy for wrong microposts" do
    log_in_as(users(:michael))
    micropost = microposts(:second_post)
    before_count = Micropost.count
    delete micropost_path(micropost)
    after_count = Micropost.count
    assert_equal before_count, after_count
    assert_redirected_to root_path
  end
end
