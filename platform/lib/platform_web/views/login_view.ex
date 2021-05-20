defmodule PlatformWeb.LoginView do
  use PlatformWeb, :view
  alias PlatformWeb.LoginView

  def render("show.json", %{login: login}) do
    render_one(login, LoginView, "login.json")
  end

  def render("login.json", %{login: login}) do
    %{token: login}
  end
end
