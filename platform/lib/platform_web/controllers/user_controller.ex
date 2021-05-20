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
      |> render("show.json", login: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Blog.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Blog.get_user!(id)

    with {:ok, %User{} = user} <- Blog.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Blog.get_user!(id)

    with {:ok, %User{}} <- Blog.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
