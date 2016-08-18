defmodule Geosnap.Db.Schema do
  @moduledoc """
  Extensions for Ecto.Schema.

  # Usage

      defmodule Foo do
        use Geosnap.Db.Schema

      end
  """

  @doc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps
      #@primary_key {:id, :binary_id, autogenerate: true}
      #@foreign_key_type :binary_id
    end
  end
end
