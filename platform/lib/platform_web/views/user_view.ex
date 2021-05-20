defmodule PlatformWeb.UserView do
  use PlatformWeb, :view

  alias PlatformWeb.LoginView

  def render("show.json", %{token: token}) do
    render_one(token, LoginView, "login.json", as: :token)
  end
end
