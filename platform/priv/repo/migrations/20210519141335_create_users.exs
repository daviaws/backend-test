defmodule Platform.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:blog_users) do
      add :displayName, :string
      add :email, :string
      add :password, :string
      add :image, :string

      timestamps()
    end

    create unique_index(:blog_users, [:email])
  end
end
