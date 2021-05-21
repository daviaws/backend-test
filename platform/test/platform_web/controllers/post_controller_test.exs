defmodule PlatformWeb.PostControllerTest do
  use PlatformWeb.ConnCase

  import Platform.Factory

  alias Platform.Blog

  @default_attrs %{
    title: "Latest updates, August 1st",
    content: "The whole text for the blog post goes here in this key"
  }

  setup %{conn: conn, tags: tags} do
    attrs = %{
      title: tags[:title] || @default_attrs[:title],
      content: tags[:content] || @default_attrs[:content]
    }

    {:ok, conn: put_req_header(conn, "accept", "application/json"), attrs: attrs}
  end

  @post_view_fields [:id, :content, :title, :inserted_at, :updated_at, :user]
  @user_view_fields [:id, :displayName, :email, :image]
  defp struct_to_map(struct, select) do
    struct
    |> Map.from_struct()
    |> Map.take(select)
  end

  defp naive_datetime_to_string_values(map) do
    map
    |> Enum.map(fn {key, value} ->
      case value do
        %NaiveDateTime{} -> {key, NaiveDateTime.to_iso8601(value)}
        _ -> {key, value}
      end
    end)
    |> Enum.into(%{})
  end

  defp normalize_user_value(map) do
    Map.put(map, :user, struct_to_map(map.user, @user_view_fields))
  end

  defp normalize_post_view(post) do
    post
    |> struct_to_map(@post_view_fields)
    |> naive_datetime_to_string_values()
    |> normalize_user_value()
  end

  defp format_bearer_token(token) do
    "Bearer \"" <> token <> "\""
  end

  defp put_bearer_token(conn, token) do
    put_req_header(conn, "authorization", token |> format_bearer_token)
  end

  defp auth_user() do
    attrs = params_for(:blog_user)
    user = insert(:blog_user, attrs)
    {:ok, token, _token_map} = Blog.login(attrs)
    {user, token}
  end

  describe "index post" do
    test "renders post when data is valid", %{conn: conn, attrs: attrs} do
      {_user, token} = auth_user()
      post1 = insert(:blog_post)
      post2 = insert(:blog_post)

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.post_path(conn, :index), attrs)

      assert response = json_response(conn, 200)

      assert Enum.map([post1, post2], &normalize_post_view/1) ==
               Enum.map(response, &Platform.Helper.Map.atomize_keys/1)
    end

    test "renders 401 without bearer token", %{conn: conn, attrs: attrs} do
      # same setup as success
      {_user, _token} = auth_user()
      _post1 = insert(:blog_post)
      _post2 = insert(:blog_post)

      conn = get(conn, Routes.post_path(conn, :index), attrs)

      assert %{"message" => "Token não encontrado"} = json_response(conn, 401)
    end

    test "renders 401 invalid bearer token", %{conn: conn, attrs: attrs} do
      conn =
        conn
        |> put_bearer_token("invalid-token")
        |> get(Routes.post_path(conn, :index), attrs)

      assert %{"message" => "Token expirado ou inválido"} = json_response(conn, 401)
    end
  end

  describe "show post" do
    test "renders post when data is valid", %{conn: conn} do
      {_user, token} = auth_user()
      post = insert(:blog_post)

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.post_path(conn, :show, post.id))

      assert normalize_post_view(post) ==
               json_response(conn, 200) |> Platform.Helper.Map.atomize_keys()
    end

    test "renders 404 when post not exist", %{conn: conn} do
      {_user, token} = auth_user()

      unexistent_post_id = 1

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.post_path(conn, :show, unexistent_post_id))

      assert %{"message" => ["Post não existe"]} = json_response(conn, 404)["errors"]
    end

    test "renders 401 without bearer token", %{conn: conn} do
      # same setup as success
      {_user, _token} = auth_user()
      post = insert(:blog_post)

      conn =
        conn
        |> get(Routes.user_path(conn, :show, post.id))

      assert %{"message" => "Token não encontrado"} = json_response(conn, 401)
    end

    test "renders 401 invalid bearer token", %{conn: conn} do
      post = insert(:blog_post)

      conn =
        conn
        |> put_bearer_token("invalid-token")
        |> get(Routes.user_path(conn, :show, post.id))

      assert %{"message" => "Token expirado ou inválido"} = json_response(conn, 401)
    end
  end

  describe "create post" do
    test "renders post when data is valid", %{conn: conn, attrs: attrs} do
      {user, token} = auth_user()

      conn =
        conn
        |> put_bearer_token(token)
        |> post(Routes.post_path(conn, :create), attrs)

      assert %{
               "content" => attrs.content,
               "title" => attrs.title,
               "userId" => user.id
             } == json_response(conn, 201)
    end

    test "renders 400 when content is not present", %{conn: conn, attrs: attrs} do
      {_user, token} = auth_user()

      attrs = Map.delete(attrs, :content)

      conn =
        conn
        |> put_bearer_token(token)
        |> post(Routes.post_path(conn, :create), attrs)

      assert %{"errors" => %{"content" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders 400 when title is not present", %{conn: conn, attrs: attrs} do
      {_user, token} = auth_user()

      attrs = Map.delete(attrs, :title)

      conn =
        conn
        |> put_bearer_token(token)
        |> post(Routes.post_path(conn, :create), attrs)

      assert %{"errors" => %{"title" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders 401 without bearer token", %{conn: conn, attrs: attrs} do
      # same setup as success
      {_user, _token} = auth_user()

      conn = post(conn, Routes.post_path(conn, :create), attrs)

      assert %{"message" => "Token não encontrado"} = json_response(conn, 401)
    end

    test "renders 401 invalid bearer token", %{conn: conn, attrs: attrs} do
      conn =
        conn
        |> put_bearer_token("invalid-token")
        |> post(Routes.post_path(conn, :create), attrs)

      assert %{"message" => "Token expirado ou inválido"} = json_response(conn, 401)
    end
  end

  # describe "update post" do
  #   setup [:create_post]

  #   test "renders post when data is valid", %{conn: conn, post: %Post{id: id} = post} do
  #     conn = put(conn, Routes.post_path(conn, :update, post), post: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.post_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "content" => "some updated content",
  #              "title" => "some updated title"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, post: post} do
  #     conn = put(conn, Routes.post_path(conn, :update, post), post: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete post" do
  #   setup [:create_post]

  #   test "deletes chosen post", %{conn: conn, post: post} do
  #     conn = delete(conn, Routes.post_path(conn, :delete, post))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.post_path(conn, :show, post))
  #     end
  #   end
  # end

  # defp create_post(_) do
  #   post = fixture(:post)
  #   %{post: post}
  # end
end
