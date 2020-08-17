defmodule XOpts.Result do
  use XOpts.Types

  @moduledoc false

  defstruct switches: %{},
            keywords: %{},
            positionals: [],
            errors: []

  @type t :: %__MODULE__{
          switches: map(),
          keywords: map(),
          positionals: list(),
          errors: error_ts()
        }
end
