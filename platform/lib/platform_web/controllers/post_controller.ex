defmodule PlatformWeb.PostController do
  use PlatformWeb, :controller

  alias Platform.Blog
  alias Platform.Blog.Post

  action_fallback PlatformWeb.FallbackController

  def index(conn, _params) do
    posts = Blog.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, params) do
    user_id = Map.get(conn.assigns[:claims], "user_id")

    with {:ok, %Post{} = post} <-
           params
           |> Map.put("user_id", user_id)
           |> Blog.create_post() do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.post_path(conn, :show, post))
      |> render("create.json", post: post)
    end
  end

  # This is a possible match of defined search route
  def show(conn, %{"id" => "search", "q" => search}) do
    with posts <- Blog.search_post(search) do
      render(conn, "index.json", posts: posts)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Post{} = post} <- Blog.get_post(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", post: post)
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, %Post{} = post} <- Blog.get_post(id),
         :ok <- authenticate_me(conn, post),
         {:ok, %Post{} = post} <- Blog.update_post(post, params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Post{} = post} <- Blog.get_post(id),
         :ok <- authenticate_me(conn, post),
         {:ok, %Post{}} <- Blog.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authenticate_me(conn, post) do
    if Map.get(conn.assigns[:claims], "user_id") == post.user_id do
      :ok
    else
      {:error, :user_forbidden}
    end
  end
end
