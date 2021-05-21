defmodule PlatformWeb.PostView do
  use PlatformWeb, :view

  alias PlatformWeb.PostView
  alias PlatformWeb.UserView

  def render("index.json", %{posts: posts}) do
    render_many(posts, PostView, "post.json")
  end

  def render("show.json", %{post: post}) do
    render_one(post, PostView, "post.json")
  end

  def render("create.json", %{post: post}) do
    %{
      userId: post.user_id,
      title: post.title,
      content: post.content
    }
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      inserted_at: post.inserted_at,
      updated_at: post.updated_at,
      user: render_one(post.user, UserView, "user.json")
    }
  end
end
