defmodule Platform.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Blog.User

  schema "blog_posts" do
    field :content, :string
    field :title, :string

    belongs_to :user, User

    timestamps()
  end

  @required [:title, :content, :user_id]

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
