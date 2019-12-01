require "digest/md5"

module UsersHelper
  def gravatar_for(user, size = "100")
    email = user.email
    hash = Digest::MD5.hexdigest(email)
    url = "https://www.gravatar.com/avatar/#{hash}"
    image_tag(url, alt: "avatar", class: "gravatar", size: size)
  end

  def button_text(controller_action)
    if controller_action == "new"
      "Create my account"
    else
      "Save changes"
    end
  end
end
