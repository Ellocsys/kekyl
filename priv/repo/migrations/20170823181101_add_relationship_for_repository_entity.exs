defmodule Kekyl.Repo.Migrations.AddRelationshipForRepositoryEntity do
  use Ecto.Migration

  def change do

     alter table(:github_repo) do
      add :content_id, references(:contents)
    end

    create index(:github_repo, [:content_id])
  end
end
