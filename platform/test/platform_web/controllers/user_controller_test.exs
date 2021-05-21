defmodule PlatformWeb.UserControllerTest do
  use PlatformWeb.ConnCase

  alias Platform.Blog

  import Platform.Factory

  @default_attrs %{
    displayName: "Brett Wiltshire",
    email: "brett@email.com",
    password: "123456",
    image:
      "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
  }

  setup %{conn: conn, tags: tags} do
    attrs = %{
      displayName: tags[:displayName] || @default_attrs[:displayName],
      email: tags[:email] || @default_attrs[:email],
      password: tags[:password] || @default_attrs[:password],
      image: tags[:image] || @default_attrs[:image]
    }

    {:ok, conn: put_req_header(conn, "accept", "application/json"), attrs: attrs}
  end

  defp format_bearer_token(token) do
    "Bearer \"" <> token <> "\""
  end

  defp put_bearer_token(conn, token) do
    put_req_header(conn, "authorization", token |> format_bearer_token)
  end

  defp auth_user(attrs) do
    {:ok, token, _token_map} = Blog.login(attrs)
    token
  end

  defp struct_to_map(struct, select) do
    struct
    |> Map.from_struct()
    |> Map.take(select)
  end

  @user_view_fields [:id, :displayName, :email, :image]

  describe "index user" do
    test "renders user when data is valid", %{conn: conn, attrs: attrs} do
      user1 = insert(:blog_user, attrs)
      user2 = insert(:blog_user)
      token = auth_user(attrs)

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.user_path(conn, :index), attrs)

      assert response = Enum.map(json_response(conn, 200), &Platform.Helper.Map.atomize_keys/1)

      assert [
               struct_to_map(user1, @user_view_fields),
               struct_to_map(user2, @user_view_fields)
             ] == response
    end

    test "renders 401 without bearer token", %{conn: conn, attrs: attrs} do
      # same setup as success
      _user1 = insert(:blog_user, attrs)
      _user2 = insert(:blog_user)
      _token = auth_user(attrs)

      conn =
        conn
        |> get(Routes.user_path(conn, :index), attrs)

      assert %{"message" => "Token não encontrado"} = json_response(conn, 401)
    end

    test "renders 401 invalid bearer token", %{conn: conn, attrs: attrs} do
      conn =
        conn
        |> put_bearer_token("invalid-token")
        |> get(Routes.user_path(conn, :index), attrs)

      assert %{"message" => "Token expirado ou inválido"} = json_response(conn, 401)
    end
  end

  describe "show user" do
    test "renders user when data is valid", %{conn: conn, attrs: attrs} do
      user1 = insert(:blog_user, attrs)
      token = auth_user(attrs)

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.user_path(conn, :show, user1.id))

      assert struct_to_map(user1, @user_view_fields) ==
               json_response(conn, 200) |> Platform.Helper.Map.atomize_keys()
    end

    test "renders 404 when user not exist", %{conn: conn, attrs: attrs} do
      user1 = insert(:blog_user, attrs)
      token = auth_user(attrs)

      user_id = user1.id + 1

      conn =
        conn
        |> put_bearer_token(token)
        |> get(Routes.user_path(conn, :show, user_id))

      assert %{"message" => ["Usuário não existe"]} = json_response(conn, 404)["errors"]
    end

    test "renders 401 without bearer token", %{conn: conn, attrs: attrs} do
      # same setup as success
      user1 = insert(:blog_user, attrs)
      _token = auth_user(attrs)

      conn =
        conn
        |> get(Routes.user_path(conn, :show, user1.id))

      assert %{"message" => "Token não encontrado"} = json_response(conn, 401)
    end

    test "renders 401 invalid bearer token", %{conn: conn, attrs: attrs} do
      user1 = insert(:blog_user, attrs)

      conn =
        conn
        |> put_bearer_token("invalid-token")
        |> get(Routes.user_path(conn, :show, user1.id))

      assert %{"message" => "Token expirado ou inválido"} = json_response(conn, 401)
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), attrs)

      assert %{"token" => token} = json_response(conn, 201)

      assert {:ok, _token_map} = PlatformWeb.JWT.Token.verify_and_validate(token)
    end

    @tag displayName: "1234567"
    test "renders errors when displayName has less than 8 characters", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders errors when email is not present`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: Map.delete(attrs, :email))

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders errors when email is nil`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: Map.put(attrs, :email, nil))

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag email: "not formated"
    test "renders errors when email is not on format `<prefix>@<domain>`", %{
      conn: conn,
      attrs: attrs
    } do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders errors when email duplicated", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders errors when password is not present`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: Map.delete(attrs, :password))

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders errors when password is nil`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: Map.put(attrs, :password, nil))

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag password: "12345"
    test "renders errors when password is lesser than 6 characters`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag password: "1234567"
    test "renders errors when password is greater than 6 characters`", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.user_path(conn, :show, id))

  #     assert %{
  #              "id" => _id,
  #              "displayName" => "some updated displayName",
  #              "email" => "some updated email",
  #              "image" => "some updated image",
  #              "password" => "some updated password"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 400)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end
end
