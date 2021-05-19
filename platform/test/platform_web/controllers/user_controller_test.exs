defmodule PlatformWeb.UserControllerTest do
  use PlatformWeb.ConnCase

  alias Platform.Blog
  alias Platform.Blog.User

  alias Platform.Helper.Map, as: HMap

  @default_attrs %{
    displayName: "Brett Wiltshire",
    email: "brett@email.com",
    password: "123456",
    image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
  }

  setup %{conn: conn, tags: tags} do
    attrs = %{
      displayName: tags[:displayName] || @default_attrs[:displayName],
      email: tags[:email] || @default_attrs[:email] ,
      password: tags[:password] || @default_attrs[:password],
      image: tags[:image] || @default_attrs[:image],
    }

    {:ok, conn: put_req_header(conn, "accept", "application/json"), attrs: attrs}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn, attrs: attrs} do
      conn = post(conn, Routes.user_path(conn, :create), user: attrs)
      
      assert %{"id" => id} = response = json_response(conn, 201)["data"]   

      assert Map.put(attrs, :id, id) == HMap.atomize_keys(response)
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
    test "renders errors when email is not on format `<prefix>@<domain>`", %{conn: conn, attrs: attrs} do
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

    # test "renders errors when email is nil`", %{conn: conn, attrs: attrs} do
    #   conn = post(conn, Routes.user_path(conn, :create), user: Map.put(attrs, :email, nil))

    #   assert json_response(conn, 400)["errors"] != %{}
    # end
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
