defmodule Platform.BlogTest do
  use Platform.DataCase

  import Platform.Factory

  alias Platform.Blog

  @user_create_fields [:displayName, :email, :image, :password]
  @post_create_fields [:content, :title, :user_id]
  defp struct_to_map(struct, select) do
    struct
    |> Map.from_struct()
    |> Map.take(select)
  end

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
      attrs = params_for(:blog_user)

      assert {:ok, %User{} = user} = Blog.create_user(attrs)
      user_attrs = struct_to_map(user, @user_create_fields)

      assert attrs == user_attrs
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

  describe "posts" do
    alias Platform.Blog.Post

    @valid_attrs %{content: "some content", title: "some title"}
    @update_attrs %{content: "some updated content", title: "some updated title"}
    @invalid_attrs %{content: nil, title: nil}

    # test "list_posts/0 returns all posts" do
    #   post = post_fixture()
    #   assert Blog.list_posts() == [post]
    # end

    # test "get_post!/1 returns the post with given id" do
    #   post = post_fixture()
    #   assert Blog.get_post!(post.id) == post
    # end

    test "create_post/1 with valid data creates a post" do
      user = insert(:blog_user)

      attrs = params_for(:blog_post)
      attrs = Map.put(attrs, :user_id, user.id)

      {:ok, post} = Blog.create_post(attrs)
      post_attrs = struct_to_map(post, @post_create_fields)

      assert attrs == post_attrs
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    # test "update_post/2 with valid data updates the post" do
    #   post = post_fixture()
    #   assert {:ok, %Post{} = post} = Blog.update_post(post, @update_attrs)
    #   assert post.content == "some updated content"
    #   assert post.title == "some updated title"
    # end

    # test "update_post/2 with invalid data returns error changeset" do
    #   post = post_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
    #   assert post == Blog.get_post!(post.id)
    # end

    # test "delete_post/1 deletes the post" do
    #   post = post_fixture()
    #   assert {:ok, %Post{}} = Blog.delete_post(post)
    #   assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    # end

    # test "change_post/1 returns a post changeset" do
    #   post = post_fixture()
    #   assert %Ecto.Changeset{} = Blog.change_post(post)
    # end
  end
end
