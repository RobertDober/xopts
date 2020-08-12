defmodule XOpts.Options do
  @moduledoc false

  use XOpts.Types

  defstruct allowed_keywords: nil,
            allowed_switches: nil,
            requested_keywords: %{},
            nof_postionals: [],
            errors: [],
            keyword_style: true,
            posix: true,
            strict: false

  @type t :: %__MODULE__{
    allowed_keywords: maybe(map()),
    allowed_switches: list(atom()),
    requested_keywords: map(),
    nof_postionals: list(non_neg_integer()),
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
