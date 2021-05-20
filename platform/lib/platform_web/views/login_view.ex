defmodule PlatformWeb.LoginView do
  use PlatformWeb, :view
  alias PlatformWeb.LoginView

  def render("show.json", %{token: token}) do
    %{data: render_one(token, LoginView, "login.json")}
  end

  def render("login.json", %{token: token}) do
    %{token: token}
  end
end
