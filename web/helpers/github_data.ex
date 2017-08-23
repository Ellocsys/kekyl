defmodule Kekyl.GithubData do

  alias Kekyl.Repo
  alias Kekyl.Section
  alias Kekyl.Content
  alias Kekyl.GithubRepo

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
  
  def parse_readme_content({content, _}) do
    Enum.find(content, [], fn(item) -> is_earmark_list item end)
    |> find_data_in_contents 
    |> Enum.map(fn(section) -> store_section section end)
  end

  def is_earmark_list(%Earmark.Block.List{}) do
    true
  end
  
  def is_earmark_list(_) do
    false
  end
  
  def is_earmark_para(%Earmark.Block.Para{}) do
    true
  end
  
  def is_earmark_para(_) do
    false
  end
  
  def is_earmark_heading_2(%Earmark.Block.Heading{level: 1}) do
    true
  end
  
  def is_earmark_heading_2(_) do
    false
  end
  
  defp find_data_in_contents(element = %Earmark.Block.List{}) do
    Enum.map(element.blocks, fn(list_item) -> find_data_in_contents list_item end)
  end
  
  defp find_data_in_contents(element = %Earmark.Block.ListItem{}) do
    Enum.map(element.blocks, fn(list_item) -> find_data_in_contents list_item end)
  end
  
  defp find_data_in_contents(element = %Earmark.Block.Para{}) do
    element.lines |> Enum.join |> split_line 
  end
  
  defp find_data_in_contents(_) do
    "unprocessed element"
  end

  def split_line(line, params \\ [:name, :link, :title] )

  def split_line(line, params ) when is_bitstring(line) do
    data = Regex.run(~r{\[([^\]]+)\]\(([^)]+)\)\W*-?\W*([^\]]+\W?)*}, line)
    |> Enum.slice(1..-1)
    Enum.zip(params, data) 
    |> Enum.into(%{})
  end
  
  def split_line(_, _) do
    %{name: "",link: ""}
  end

  def update_or_insert(object, search_param) do
    db_struct = case Repo.get_by(object.__struct__, search_param) do
      nil -> object
      post -> post
    end
    section_changeset = object.__struct__.changeset(db_struct, search_param)
    Repo.insert_or_update(section_changeset)
  end

  def store_section([content|items]) do
    {:ok, section_entity} = update_or_insert(%Section{}, content)
    List.flatten(items)
    |> Enum.map(fn(item) -> 
      item_map = Enum.into(%{}, item)
      search_params = Map.put(item_map, :section_id, section_entity.id)
      update_or_insert(%Content{}, search_params)  
    end)
  end

  def store_repos(item) do
    # item.repos
    content_entity = case Repo.get_by(Content, %{name: item.name}) do
      nil -> nil
      post -> post
    end
    Enum.map(item.repos, fn(repo) -> 
      repo_map = Enum.into(%{}, repo)
      search_params = Map.put(repo_map, :content_id, content_entity.id)
      update_or_insert(%GithubRepo{}, search_params)  
    end)
  end

  def parse_readme_repositiries({content, _}) do
    content
    |> Enum.slice(5..-1)
    |> remove_heading
    |> Enum.chunk(3)
    |> Enum.map(fn([heading, para, list]) -> 
      %{name: heading.content, title: Enum.join(para.lines), repos: List.flatten(find_data_in_contents(list)) }
    end )
    |> Enum.map(fn(section) -> store_repos section end)
  end

  def remove_heading(list) do
    index = Enum.find_index(list, fn(item) -> is_earmark_heading_2(item) end)
    if index do
      # Удаляем h1 заголовок и описание к нему
      new_list = List.delete_at(list, index)
      |> List.delete_at(index)
      remove_heading(new_list)
    else
      list
    end
  end

end
