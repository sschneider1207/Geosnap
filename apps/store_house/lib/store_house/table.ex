defmodule StoreHouse.Table do
  @moduledoc """
  Convience macro for using mnesia records.  Records are defined in the
  "src/records.hrl" file.

  # Usage

  Use this module in another one and pass the name of a record as the argument.

      defmodule Foo do
        use StoreHouse.Table, :foo
        ...
      end

  In this case, the record for `:foo` is extracted from the record definitions
  file and is passed to`Record.defrecord/2`/`Kernel.defstruct/1`.

  In addition, a `row_to_struct/1` function is defined in order to convert
  a mnesia record to a struct representation.

  """

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
      @spec struct(tuple) :: t
      def struct(row) do
        struct(__MODULE__, unquote(name)(row))
      end
    end
  end
end
