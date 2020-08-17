defmodule XOpts.Options do
  @moduledoc false

  use XOpts.Types

  import XOpts.Ext.Enum, only: [number_list: 1]

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

  @type user_options_t :: t() | map() | Keyword.t()

  @spec check(t()) :: either(t(), config_error_ts())
  def check(options) do
    errors = _check_allowed_keywords(options.allowed_keywords, [])
    errors1 = _check_required_keywords(options.required_keywords, errors)

    errors2 =
      _check_positional_constraints(options.positional_constraints |> number_list(), errors1)

    case errors2 do
      [] -> {:ok, options}
      _ -> {:error, errors2}
    end
  end

  @spec new(user_options_t()) :: t()
  def new(source)

  def new(%__MODULE__{} = options) do
    options
  end

  def new(options) do
    struct(__MODULE__, options)
  end

  defp _check_allowed_keywords(allowed_keywords, errors)
  defp _check_allowed_keywords(nil, errors), do: errors

  defp _check_allowed_keywords(allowed_keywords, errors) do
    _check_allowed_keywords_as_kwds(allowed_keywords |> Enum.into([]), errors)
  end

  defp _check_allowed_keywords_as_kwds(allowed_keywords, errors)
  defp _check_allowed_keywords_as_kwds([], errors), do: errors

  defp _check_allowed_keywords_as_kwds([{kwd, definition} | rest], errors) do
    case _check_definition(kwd, definition) do
      [] -> _check_allowed_keywords_as_kwds(rest, errors)
      errors1 -> _check_allowed_keywords_as_kwds(rest, errors1 ++ errors)
    end
  end

  @spec _check_definition(position_t(), complex_definition_t()) :: config_error_ts()
  defp _check_definition(kwd_or_index, definition_tuple)

  defp _check_definition(kwd_or_index, {_type, definition}) do
    _check_empty_range(kwd_or_index, definition) ++
      _check_illegal_default(kwd_or_index, definition)
  end

  defp _check_definition(_kwd_or_index, _), do: []

  @spec _check_empty_range(position_t(), definition_kwd_t()) :: config_error_ts()
  defp _check_empty_range(kwd_or_index, definition) do
    min = Keyword.get(definition, :min)
    max = Keyword.get(definition, :min)

    if min && max && max < min do
      [{:empty_range, Keyword.merge(_make_position(kwd_or_index), min: min, max: max)}]
    else
      []
    end
  end

  @spec _check_illegal_default(position_t(), definition_kwd_t()) :: config_error_ts()
  defp _check_illegal_default(kwd_or_index, definition) do
    min = Keyword.get(definition, :min)
    max = Keyword.get(definition, :min)
    default = Keyword.get(definition, :default)

    cond do
      default && min && default < min ->
        [
          {:illegal_default,
           Keyword.merge(_make_position(kwd_or_index), default: default, min: min)}
        ]

      default && max && default < max ->
        [
          {:illegal_default,
           Keyword.merge(_make_position(kwd_or_index), default: default, max: max)}
        ]

      true ->
        []
    end
  end

  defp _check_required_keywords(required_keywords, errors) do
    _check_required_keywords_as_kwds(required_keywords |> Enum.into([]), errors)
  end

  defp _check_required_keywords_as_kwds(required_keywords, errors)
  defp _check_required_keywords_as_kwds([], errors), do: errors

  defp _check_required_keywords_as_kwds([{_kwd, _definitions} | _rest], errors) do
    errors
  end

  @spec _check_positional_constraints(numbered_list(any()), error_ts()) :: error_ts()
  defp _check_positional_constraints(constraints, errors)
  defp _check_positional_constraints([], errors), do: errors

  defp _check_positional_constraints([type | rest], errors) when is_atom(type) do
    _check_positional_constraints(rest, errors)
  end

  defp _check_positional_constraints([{definition, index} | rest], errors)
       when is_tuple(definition) do
    _check_positional_constraints(rest, _check_definition(index, definition) ++ errors)
  end

  @spec _make_position(position_t()) :: [{:position, pos_integer()}] | [{:keyword, atom()}]
  defp _make_position(kwd_or_index)
  defp _make_position(kwd_or_index) when is_atom(kwd_or_index), do: [keyword: kwd_or_index]
  defp _make_position(kwd_or_index), do: [position: kwd_or_index]
end
