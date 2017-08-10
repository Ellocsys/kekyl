defmodule Kekyl.GithubDataTest do
    use ExUnit.Case
    alias Kekyl.GithubData

   @valid_earmark_tree {[%Earmark.Block.Para{attrs: nil,lines: ["test line"],lnb: 4}], %Earmark.Context{}} 

   test "get_repo_readme - valid repository" do
      {:ok, {_, %Earmark.Context{}}} = Kekyl.GithubData.get_repo_readme("h4cc", "awesome-elixir")
   end
   
   test "get_repo_readme - invalid repository" do
      {:error, "Invalid URL"} == Kekyl.GithubData.get_repo_readme("nvjrebnvi", "bvurjebvire")
   end

end
