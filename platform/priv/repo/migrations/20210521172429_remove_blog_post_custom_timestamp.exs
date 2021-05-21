defmodule Platform.Repo.Migrations.RemoveBlogPostCustomTimestamp do
  use Ecto.Migration

  def up do
    alter table(:blog_posts) do
      remove :publihed
      remove :updated
    end
  end

  def down do
    alter table(:blog_posts) do
      add :publihed, :naive_datetime
      add :updated, :naive_datetime
    end
  end
end
