defmodule PlatformWeb.UserController do
  use PlatformWeb, :controller

  alias Platform.Blog
  alias Platform.Blog.User

  action_fallback PlatformWeb.FallbackController

  def index(conn, _params) do
    users = Blog.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, params) do
    with {:ok, %User{}} <- Blog.create_user(params),
         {:ok, token, _token_map} <- Blog.login(params) do
      conn
      |> put_status(:created)
      |> render("login.json", login: token)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Blog.get_user(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", user: user)
    end
  end

  def delete(conn, _params) do
    id = Map.get(conn.assigns[:claims], "user_id")

    with {:ok, %User{} = user} <- Blog.get_user(id),
         {:ok, %User{}} <- Blog.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
