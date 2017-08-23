defmodule Kekyl.GithubRepo do
  use Kekyl.Web, :model

  schema "github_repo" do
    field :name, :string
    field :link, :string
    field :stars, :integer , default: 0
    field :last_commit, Ecto.Date
    field :title, :string
    belongs_to :content, Kekyl.Content

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :link, :stars, :last_commit, :title, :content_id])
    |> validate_required([:name, :link, :title, :content_id])
  end
end
