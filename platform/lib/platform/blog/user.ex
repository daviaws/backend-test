defmodule Platform.Blog.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Blog.Post
  alias Platform.Blog.User

  schema "blog_users" do
    field :displayName, :string
    field :email, :string
    field :image, :string
    field :password, :string

    has_many :blog_posts, Post

    timestamps()
  end

  @required [:displayName, :email, :password, :image]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_length(:displayName, min: 8)
    |> validate_format(:email, ~r/[a-zA-Z0-9-]+@[a-zA-Z0-9-]+/,
      message: "must be a valid format `name@domain`"
    )
    |> unique_constraint(:email, message: "Usuário já existe")
    |> validate_length(:password, min: 6, max: 6)
  end

  def empty_changeset() do
    cast(%User{}, %{}, [])
  end
end
