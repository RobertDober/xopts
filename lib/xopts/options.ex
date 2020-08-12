defmodule XOpts.Options do
  @moduledoc false

  use XOpts.Types

  defstruct allowed_keywords: nil,
            allowed_switches: nil,
            requested_keywords: %{},
            errors: [],
            keyword_style: true,
            posix: true

  @type t :: %__MODULE__{
    allowed_keywords: maybe(map()),
    allowed_switches: list(atom()),
    requested_keywords: map(),
    keyword_style: boolean(),
    posix: boolean()
  }

  @spec new(map() | t() | Keyword.t) :: t()
  def new(source)
  def new(%__MODULE__{}=options) do
    options
  end
  def new(options) do
    struct(__MODULE__, options)
  end
end
