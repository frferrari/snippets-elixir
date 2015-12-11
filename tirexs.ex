# snippets-elixir
#
# Here are some examples of Elixir code that show how to access an ElasticSearch db using the Tirexs library
#
defmodule ElasticSearch do
  require Tirexs.ElasticSearch

  #
  #
  #
  @doc "Returns ElasticSearch settings"
  def get_settings do
    Tirexs.ElasticSearch.config()
  end

end

#
#
#
defmodule ElasticSearch.Auctions do
  @auctions_index "auctions"
  
  import Tirexs.Search  
  import Tirexs.Mapping
  require Tirexs.ElasticSearch
  
  @doc "Get a count of all documents in the auctions index"
  def get_count(settings \\ ElasticSearch.get_settings) do
    {:ok, 200, %{_shards: _, count: cnt}} = Tirexs.Manage.count([index: @auctions_index], settings)
    cnt
  end

  @doc "Delete the auctions index"
  def delete_index(settings \\ ElasticSearch.get_settings) do
    Tirexs.ElasticSearch.delete(@auctions_index, settings)
  end
  
  @doc "Get a list of auctions starting at offset and for a count of page_size auctions"
  def get_chunk(offset, page_size, settings \\ ElasticSearch.get_settings) do
    find_auctions = search [index: @auctions_index] do
      query do
        string "id:*"
      end
      sort do
        [
          [id: "asc"]
        ]
      end
    end
    {:result, count, _, _, results, _} = Tirexs.Query.create_resource(find_auctions, settings, [{:from, offset}, {:size, page_size}])
    {count, results |> Enum.map(fn(%{_id: _, _index: _, _score: _, _source: auctions, _type: _, sort: _}) -> auctions end)}
  end
end
