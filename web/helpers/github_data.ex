defmodule GithubData do

  @table_name :github_data

  def inicialize_data() do
    :ets.new(@table_name, [:named_table, :public, read_concurrency: true])
    :ets.insert(@table_name, {"awesome_readme", get_repo_readme()})
  end

  @doc """
  Получает и конвертирует в earmark tree содержимое файла readme.md для указанного репозитория
  """
  @spec get_repo_readme(owner :: String.t, repo :: String.t, client :: Tentacat.Client) :: String
  def get_repo_readme(owner \\ "h4cc", repo \\ "awesome-elixir" , client \\ Tentacat.Client.new()) do
    {_, md_text} = Tentacat.Contents.find(owner, repo, "README.md", client)["content"] |> Base.decode64(ignore: :whitespace) 
    Earmark.parse(md_text)
  end

end
