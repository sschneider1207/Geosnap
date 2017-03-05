defmodule StoreHouse.Table do

  defmacro __using__(name) do
    attrs = Record.extract(name, from: "src/records.hrl")
    quote location: :keep, bind_quoted: [name: name, attrs: attrs] do
      import Record
      defrecord name, attrs
      defstruct attrs

      @typedoc """
      Struct representation of a(n) #{name} record.
      """
      @type t :: %__MODULE__{}

      @doc """
      Converts a(n) #{name} record into a struct.
      """
      @spec row_to_struct(tuple) :: t
      def row_to_struct(row) do
        struct(__MODULE__, unquote(name)(row))
      end
    end
  end
end
