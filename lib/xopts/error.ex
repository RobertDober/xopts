defmodule XOpts.Error do
  @moduledoc false

  defexception [:message]

  @doc false

  @spec exception( binary() ) :: Exception.t 
  def exception(msg), do: %__MODULE__{message: msg}
end
