defmodule Kekyl.GithubRepoTest do
  use Kekyl.ModelCase

  alias Kekyl.GithubRepo

  @valid_attrs %{last_commit: %{day: 17, month: 4, year: 2010}, link: "some content", name: "some content", stars: 42, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GithubRepo.changeset(%GithubRepo{}, @invalid_attrs)
    refute changeset.valid?
  end
end
