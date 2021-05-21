defmodule PlatformWeb.UserView do
  use PlatformWeb, :view

  alias PlatformWeb.LoginView
  alias PlatformWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      image: user.image
    }
  end

  def render("login.json", %{login: login}) do
    render_one(login, LoginView, "login.json")
  end
end
