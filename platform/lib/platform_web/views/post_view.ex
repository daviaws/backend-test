defmodule PlatformWeb.PostView do
  use PlatformWeb, :view
  alias PlatformWeb.PostView

  def render("index.json", %{posts: posts}) do
    render_many(posts, PostView, "post.json")
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("post.json", %{post: post}) do
    %{
      userId: post.user_id,
      title: post.title,
      content: post.content
    }
  end
end
