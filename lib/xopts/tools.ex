defmodule XOpts.Tools do
  
  @moduledoc """
  Implements functionality needed by the parser `XOpts.parser`as well as by the macro part `XOpts`needed.
  """
  @defined_types %{
    boolean: false,
    float: 0.0,
    integer: 0,
    string: "",
  }
  

  def make_options(xoptions, parsed, result)
  def make_options([], _, result), do: result
  def make_options([{:group_option, name, group, _}|rest], parsed, result) do
    value = case Keyword.get(parsed, name) do
      nil -> false
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, [{name, value}|result])
  end
  def make_options([{name, type, :group, group}|rest], parsed, result) do
    value = case Keyword.get(parsed, name) do
      nil -> example_value(type, nil)
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, [{name, value}|result])
  end
  def make_options([{name, type, default, _}|rest], parsed, result) do
    value = case Keyword.get(parsed, name) do
      nil -> example_value(type, default)
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, [{name, value}|result])
  end
  
  defp example_value(type, explicit_default) do
    case explicit_default do
      nil -> example_value!(type)
      _   -> explicit_default
    end
  end

  defp example_value!(type) do
    if Map.has_key?(@defined_types, type) do
      Map.get(@defined_types, type)
    else
      raise """
      Undefined XOpts type #{type}!
      Defined Types and their default values are:
      #{inspect @defined_types}
      """
    end
  end
end
