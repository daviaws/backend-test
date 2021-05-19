defmodule Platform.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Blog.User

  schema "blog_posts" do
    field :content, :string
    field :publihed, :naive_datetime
    field :title, :string
    field :updated, :naive_datetime

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :publihed, :updated])
    |> validate_required([:title, :content, :publihed, :updated])
    |> cast_assoc(:user, required: true)
  end
end
