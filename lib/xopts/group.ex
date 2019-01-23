defmodule XOpts.Group do
  defstruct values: %{}, all_selected?: false
  @type t :: %__MODULE__{values: map(), all_selected?: boolean()}
end
