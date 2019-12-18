require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select ".pagination"
    assert_select 'input[type=file]'

    # invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error-explanation"

    # valid submission
    content = "test micropost content"
    picture = fixture_file_upload("test/fixtures/rails.png", "image/png")
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture} }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_match content, response.body

    # delete post
    assert_select "a", text: "Delete Post"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end

    # visit different user(no delete links)
    get user_path(users(:shafrazi))
    assert_select "a", text: "Delete Post", count: 0

    # sidebar micropost count
    get root_path
    assert_match @user.microposts.count.to_s, response.body
  end
end
