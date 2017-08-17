defmodule Kekyl.GithubDataTest do
    use ExUnit.Case
    alias Kekyl.GithubData

   @valid_earmark_tree {[%Earmark.Block.Para{attrs: nil,lines: ["[test](#line)"],lnb: 4}], %Earmark.Context{}} 
   @valid_earmark_list %Earmark.Block.List{attrs: nil, blocks: [],lnb: 4} 
   @random_list ["test", {11, "random"}]

   test "get_repo_readme - valid repository" do
      {:ok, {_, %Earmark.Context{}}} = GithubData.get_repo_readme("h4cc", "awesome-elixir")
   end
   
   test "get_repo_readme - invalid repository" do
      {:error, "Invalid URL"} == GithubData.get_repo_readme("nvjrebnvi", "bvurjebvire")
   end

   test "is_earmark_list - right list item" do
       true == GithubData.is_earmark_list(@valid_earmark_list)
   end
   
   test "is_earmark_list - wrong list item" do
       false == GithubData.is_earmark_list(@random_list)
   end

#    test "find_data_in_contents - Para item" do


end
