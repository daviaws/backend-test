defmodule PlatformWeb.UserView do
  use PlatformWeb, :view
  alias PlatformWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      displayName: user.displayName,
      email: user.email,
      password: user.password,
      image: user.image}
  end
end
