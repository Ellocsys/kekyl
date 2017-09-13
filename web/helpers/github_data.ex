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

  def get_repo_additional_info(owner \\ "h4cc", repo \\ "awesome-elixir" , client \\ Tentacat.Client.new()) do
    repo_info = Tentacat.Repositories.repo_get(owner, repo, client)
    branch_info = Tentacat.Repositories.Branches.find(owner, repo, repo_info["default_branch"], client)
    %{stars: repo_info["stargazers_count"],last_comit: branch_info["commit"]["commit"]["author"]["date"]}
  end

  defp parse_repo_readme({404,_}) do
    {:error, "parse_repo_readme: invalid URL"}
  end

  defp parse_repo_readme(responce) when is_map(responce) do
    {:ok, markdown_markup} = responce["content"] |> Base.decode64(ignore: :whitespace)
    earmark_tree = Earmark.parse(markdown_markup)
    {:ok, earmark_tree}
  end

  defp parse_repo_readme(_) do
    {:error, "parse_repo_readme: unxpected result"}
  end
  

 
  def parse_readme_content({:ok, {content, _}}) do
    # Вытащим интересующи нас список(к сожалениюю не придумал как более изящно это сделать 
    # т.к. у списка нет никаких отличительных черт)
    contents_list = Enum.find(content, [], fn(item) -> is_earmark_list item end) 
    content_list = List.first(contents_list.blocks)
    
    Enum.find(content_list.blocks, [], fn(item) -> is_earmark_list item end) 
    |> find_data_in_contents 
    |> List.flatten
    |> Enum.map(fn(section) -> update_or_insert(%Content{}, section)  end)
  end
  
  def parse_readme_content({:error, message}) do
    "parse_readme_content: can't parse contents section (#{message})"
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

  # На самом деле эта функция подойдет для того что бы распарсить все оглавление
  # (включая секцию resource и contributing)
  # Но это не входит в требования к заданию
  
  defp find_data_in_contents(element = %Earmark.Block.List{}) do
    Enum.map(element.blocks, fn(list_item) -> find_data_in_contents list_item end)
  end
  
  defp find_data_in_contents(element = %Earmark.Block.ListItem{}) do
    Enum.map(element.blocks, fn(list_item) -> find_data_in_contents list_item end)
  end
  
  defp find_data_in_contents(element = %Earmark.Block.Para{}) do
    data = element.lines 
    |> Enum.join 
    |> Earmark.Helpers.LinkParser.parse_link(Earmark.Options)
    |> Tuple.to_list
    |> Enum.slice(1..2)
    Enum.zip([:name, :link, :title], data)
    |> Enum.into(%{})
  end
  
  defp find_data_in_contents(_) do
    "unprocessed element"
  end

  def split_line(line, regex, params \\ [:name, :link, :title] )

  def split_line(line, regex, params ) when is_bitstring(line) do
      data = Regex.run(regex, line)
      |> Enum.slice(1..-1)
      Enum.zip(params, data)
      |> Enum.into(%{})
  end
  
  def split_line(_,_, _) do
    %{name: "",link: ""}
  end

  def update_or_insert(object, search_param, additional_params \\ %{}) do
    db_struct = case Repo.get_by(object.__struct__, search_param) do
      nil -> object
      post -> post
    end
    params = Map.merge(search_param, additional_params)
    section_changeset = object.__struct__.changeset(db_struct, params)
    Repo.insert_or_update(section_changeset)
  end

  def store_repos(item) do
    content_entity = case Repo.get_by(Content, %{name: item.name}) do
      nil -> nil
      post -> post
    end
    # content_entity
    Enum.map(item.repos, fn(repo) -> 
      repository_entitty = Map.put(repo, :content_id, content_entity.id)
      # additional_params = get_repo_additional_info(Enum.at(parsed_url, 1),Enum.at(parsed_url, 2))
      # update_or_insert(%GithubRepo{}, search_params, additional_params)  
    end)
  end

  def parse_readme_repositiries({:ok, {content, _}}) do
    content
    |> Enum.slice(5..-1)
    |> Enum.take_while(fn(item) -> not is_earmark_heading_2(item) end)
    |> Enum.chunk(3) 
    |> Enum.map(fn([heading, para, list]) -> 
      # heading
      %{
      name: heading.content,
      title: Enum.join(para.lines), 
      repos: find_data_in_contents(list) 
             |> List.flatten |> Enum.filter(fn(link) ->  split_line( link.link, ~r{\[([^\]]+)\]\(([^)]+)\)\W*-?\W*([^\]]+\W?)*} ) end) }
    end )
    # |> Enum.map(fn(section) -> store_repos section end)
  end

end
