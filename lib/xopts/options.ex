defmodule XOpts.Options do
  @moduledoc false

  use XOpts.Types

  defstruct allowed_keywords: nil,
            allowed_switches: nil,
            required_keywords: %{},
            nof_postionals: [],
            positional_constraints: [],
            errors: [],
            keyword_style: true,
            posix: true,
            strict: false

  @type t :: %__MODULE__{
    allowed_keywords: maybe(map()),
    allowed_switches: list(atom()),
    required_keywords: map(),
    nof_postionals: list(non_neg_integer()),
    positional_constraints: list(),
    keyword_style: boolean(),
    posix: boolean(),
    strict: boolean()
  }

  @type user_options_t :: t() | map() | Keyword.t

  @spec new(user_options_t()) :: t()
  def new(source)
  def new(%__MODULE__{}=options) do
    options
  end
  def new(options) do
    struct(__MODULE__, options)
  end
end
