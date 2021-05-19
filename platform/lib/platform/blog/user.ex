defmodule Platform.Blog.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Blog.Post

  schema "blog_users" do
    field :displayName, :string
    field :email, :string
    field :image, :string
    field :password, :string

    has_many :blog_posts, Post

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:displayName, :email, :password, :image])
    |> validate_required([:displayName, :email, :password, :image])
  end
end
