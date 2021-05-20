defmodule PlatformWeb.LoginController do
  use PlatformWeb, :controller

  alias Platform.Blog

  action_fallback PlatformWeb.FallbackController

  def create(conn, params) do
    with {:ok, token, _token_map} <- Blog.login(params) do
      conn
      |> put_status(:ok)
      |> render("show.json", login: token)
    end
  end
end
