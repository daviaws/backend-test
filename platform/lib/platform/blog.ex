defmodule Platform.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Platform.Repo

  alias Platform.Blog.Login
  alias Platform.Blog.Post
  alias Platform.Blog.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Get a user.

  ## Examples

      iex> get_user(existent_id)
      {:ok, %Post{}}

      iex> get_user(inexistent_id)
      {:error, %Ecto.Changeset{message: "Usuário não existe"}}

  """
  def get_user(id) do
    case Repo.get(User, id) do
      nil ->
        {
          :error,
          Ecto.Changeset.add_error(User.empty_changeset(), :message, "Usuário não existe")
        }

      user ->
        {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Return a JWT to do authenticated actions

  ## Examples

      iex> login(valid_credentials)
      {:ok, token, claims}

      iex> login(invalid_credentials)
      {:error, %Ecto.Changeset{}}

  """
  def login(attrs) do
    {user, changeset} = Login.validate(attrs)

    if changeset.valid? do
      PlatformWeb.JWT.Token.generate_and_sign(%{"user_id" => user.id})
    else
      {:error, changeset}
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{user: preloaded_user}, ...]

  """
  def list_posts do
    Post
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Get a post.

  ## Examples

      iex> get_post(existent_post_id)
      {:ok, %Post{}}

      iex> get_post(inexistent_post_id)
      {:error, %Ecto.Changeset{message: "Post não existe"}}

  """
  def get_post(id) do
    case Repo.get(Post, id) do
      nil ->
        {
          :error,
          Ecto.Changeset.add_error(
            %Platform.Blog.Post{} |> Ecto.Changeset.change(),
            :message,
            "Post não existe"
          )
        }

      post ->
        {:ok, Repo.preload(post, :user)}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Return all posts matching the search param
  Conditions:
    search %ilike% title
    search %ilike% content

  If none matches return empty list

  ## Examples

      iex> search_post(matching_title_or_content)
      [%Post{user: preloaded_user}, ...]

      iex> search_post(not_matching)
      []

  """
  def search_post(search) do
    search = "%#{search}%"

    query =
      from post in Post,
        where: ilike(post.title, ^search),
        or_where: ilike(post.content, ^search),
        preload: :user

    Repo.all(query)
  end
end
