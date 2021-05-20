defmodule PlatformWeb.UserView do
  use PlatformWeb, :view

  alias PlatformWeb.LoginView

  def render("show.json", %{login: login}) do
    render_one(login, LoginView, "login.json")
  end
end
