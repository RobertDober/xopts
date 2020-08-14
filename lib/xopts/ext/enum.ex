defmodule XOpts.Ext.Enum do
  @moduledoc false

  @spec number_list(list(t), integer(), integer()) :: list({t, integer()}) when t: any()
  def number_list(list, start_at \\ 1, increment_by \\ 1) do
    list
    |> Stream.zip(Stream.iterate(start_at, &(&1+increment_by)))
    |> Enum.to_list
  end
end
