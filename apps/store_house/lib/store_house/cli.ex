defmodule StoreHouse.CLI do

  def start do
    Application.ensure_all_started(:store_house)
  end

  def create_schema do
    disc_nodes()
    |> :mnesia.create_schema()
  end

  def delete_schema do
    disc_nodes()
    |> :mnesia.delete_schema()
  end

  defp disc_nodes do
    Application.get_env(:store_house, :disc_nodes, [])
  end

  def init do
    records = Record.extract_all(from: "src/records.hrl")
    for {table_name, definition} <- Application.get_env(:store_house, :table_definitions) do
      attrs = case Keyword.get(definition, :record_name) do
        nil -> table_name
        name -> name
      end
      |> attrs_from_records(records)
      {table_name, :mnesia.create_table(table_name, [{:attributes, attrs}|definition])}
    end
  end

  defp attrs_from_records(name, records) do
    Keyword.get(records, name)
    |> Keyword.keys()
  end
end
