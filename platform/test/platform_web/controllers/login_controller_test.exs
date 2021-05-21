defmodule PlatformWeb.LoginControllerTest do
  use PlatformWeb.ConnCase

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

  describe "create login" do
    test "renders a JWT with user_id when data is valid", %{conn: conn, attrs: attrs} do
      user = insert(:blog_user, attrs)
      user_id = user.id

      conn = post(conn, Routes.login_path(conn, :create), attrs)

      assert %{"token" => token} = json_response(conn, 200)

      assert {:ok, %{"user_id" => ^user_id}} = PlatformWeb.JWT.Token.verify_and_validate(token)
    end

    test "renders 400 when email is not present", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.login_path(conn, :create), Map.delete(attrs, :email))

      assert %{"errors" => %{"email" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders 400 when password is not present", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.login_path(conn, :create), Map.delete(attrs, :password))

      assert %{"errors" => %{"password" => ["can't be blank"]}} = json_response(conn, 400)
    end

    @tag email: ""
    test "renders 400 when email is empty string", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.login_path(conn, :create), attrs)

      assert attrs.email == ""

      assert %{"errors" => %{"email" => ["is not allowed to be empty"]}} =
               json_response(conn, 400)
    end

    test "renders 400 when user do not exist", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.login_path(conn, :create), attrs)

      assert %{"errors" => %{"message" => ["Campos inválidos"]}} = json_response(conn, 400)
    end
  end
end
