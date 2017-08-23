defmodule Kekyl.Repo.Migrations.CreateContent do
  use Ecto.Migration

  def change do
    create table(:contents) do
      add :name, :string
      add :link, :string

      timestamps()
    end

  end
end
