defmodule Kekyl.Repo.Migrations.CreateGithubRepo do
  use Ecto.Migration

  def change do
    create table(:github_repo) do
      add :name, :string
      add :link, :string
      add :stars, :integer
      add :last_commit, :date
      add :title, :string

      timestamps()
    end

  end
end
