defmodule Kekyl.Content do
  use Kekyl.Web, :model

  schema "contents" do
    field :name, :string
    field :link, :string
    has_many :contents, Kekyl.GithubRepo

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :link])
    |> validate_required([:name, :link])
  end
end
