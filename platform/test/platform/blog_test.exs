defmodule Platform.BlogTest do
  use Platform.DataCase

  import Platform.Factory

  alias Platform.Blog

  describe "users" do
    alias Platform.Blog.User

    @invalid_attrs %{displayName: nil, email: nil, image: nil, password: nil}

    # def user_fixture(attrs \\ %{}) do
    #   {:ok, user} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Blog.create_user()

    #   user
    # end

    # test "list_users/0 returns all users" do
    #   user = user_fixture()
    #   assert Blog.list_users() == [user]
    # end

    # test "get_user!/1 returns the user with given id" do
    #   user = user_fixture()
    #   assert Blog.get_user!(user.id) == user
    # end

    test "create_user/1 with valid data creates a user" do
      params = params_for(:blog_user)

      assert {:ok, %User{} = user} = Blog.create_user(params)

      assert user.displayName == params.displayName
      assert user.email == params.email
      assert user.image == params.image
      assert user.password == params.password
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_user(@invalid_attrs)
    end

    # test "update_user/2 with valid data updates the user" do
    #   user = user_fixture()
    #   assert {:ok, %User{} = user} = Blog.update_user(user, @update_attrs)
    #   assert user.displayName == "some updated displayName"
    #   assert user.email == "a@c"
    #   assert user.image == "some updated image"
    #   assert user.password == "some updated password"
    # end

    # test "update_user/2 with invalid data returns error changeset" do
    #   user = user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Blog.update_user(user, @invalid_attrs)
    #   assert user == Blog.get_user!(user.id)
    # end

    # test "delete_user/1 deletes the user" do
    #   user = user_fixture()
    #   assert {:ok, %User{}} = Blog.delete_user(user)
    #   assert_raise Ecto.NoResultsError, fn -> Blog.get_user!(user.id) end
    # end

    # test "change_user/1 returns a user changeset" do
    #   user = user_fixture()
    #   assert %Ecto.Changeset{} = Blog.change_user(user)
    # end
  end
end
