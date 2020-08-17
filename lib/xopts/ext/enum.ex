defmodule XOpts.Ext.Enum do
  @moduledoc false

  use XOpts.Types

  @spec number_list(list(t), integer(), integer()) :: numbered_list(t) when t: any()
  def number_list(list, start_at \\ 1, increment_by \\ 1) do
    list
    |> Stream.zip(Stream.iterate(start_at, &(&1 + increment_by)))
    |> Enum.to_list()
  end
end
