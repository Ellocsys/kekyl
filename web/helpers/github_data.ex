defmodule Kekyl.GithubData do

  import Kekyl.EarmarkTypeChecker

  @table_name :github_data
  @record_name "awesome_readme"

  def inicialize_data() do
    {:ok, ermark_tree} = get_repo_readme()
    :ets.new(@table_name, [:named_table, :public, read_concurrency: true])
    :ets.insert(@table_name, {@record_name, ermark_tree})
  end

  # Секция с кодом для парсинга readme

  @doc """
  Получает и конвертирует в earmark tree содержимое файла readme.md для указанного репозитория
  """
  @spec get_repo_readme(owner :: String.t, repo :: String.t, client :: Tentacat.Client) :: String
  def get_repo_readme(owner \\ "h4cc", repo \\ "awesome-elixir" , client \\ Tentacat.Client.new) do
    Tentacat.Contents.find(owner, repo, "README.md", client) |> parse_repo_readme
  end

  defp parse_repo_readme({404,_}) do
    {:error, "Invalid URL"}
  end

  defp parse_repo_readme(responce) when is_map(responce) do
    {:ok, markdown_markup} = responce["content"] |> Base.decode64(ignore: :whitespace)
    earmark_tree = Earmark.parse(markdown_markup)
    {:ok, earmark_tree}
  end

  defp parse_repo_readme(_) do
    {:error, "parse_repo_readme - unxpected result"}
  end
  
  def parse_readme_content({content, context}) do
    contents_list = Enum.find(content, [], fn(item) -> is_earmark_list item end)
  end

  def is_earmark_list(%Earmark.Block.List{}) do
    true
  end
  
  def is_earmark_list(_) do
    false
  end

  def store_readme_contents( element = %Earmark.Block.List{}, depth \\ 0) do
    Enum.map(element.blocks, fn(list_item) -> store_readme_contents(list_item, depth+1) end)
  end
  
  def store_readme_contents( element = %Earmark.Block.ListItem{}, depth) do
    Enum.map(element.blocks, fn(list_item) -> store_readme_contents(list_item, depth+1) end)
  end
  
  def store_readme_contents( element = %Earmark.Block.Para{}, 2) do
    "header"
  end
  
  def store_readme_contents( element = %Earmark.Block.Para{}, 4) do
    "element"
  end







end
