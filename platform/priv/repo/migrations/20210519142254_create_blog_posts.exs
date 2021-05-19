defmodule Platform.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string
      add :content, :text
      add :publihed, :naive_datetime
      add :updated, :naive_datetime
      add :user_id, references(:blog_users, on_delete: :nothing)

      timestamps()
    end

    create index(:blog_posts, [:user_id])
  end
end
