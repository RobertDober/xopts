defmodule XOpts.Tools do

  alias XOpts.Error
  alias XOpts.Group
  
  @moduledoc """
  Implements functionality needed by the parser `XOpts.parser`as well as by the macro part `XOpts`needed.
  """
  @defined_types %{
    boolean: false,
    float: 0.0,
    integer: 0,
    string: "",
  }
  

  def make_options(xoptions, parsed, groups, result)
  def make_options([], _, _, result), do: result
  def make_options([{:group_option, name, _group, _}|rest], parsed, groups, result) do
    value = case Keyword.get(parsed, name) do
      nil -> false
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, groups, [{name, value}|result])
  end
  def make_options([{name, type, :group, group}|rest], parsed, groups, result) do
    value = case Keyword.get(parsed, name) do
      nil -> example_value(type, groups[group], nil)
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, groups, [{name, value}|result])
  end
  def make_options([{name, type, default, _}|rest], parsed, groups, result) do
    value = case Keyword.get(parsed, name) do
      nil -> example_value(type, nil, default)
      parsed_value -> parsed_value
    end
    make_options(rest, parsed, groups, [{name, value}|result])
  end
  
  defp example_value(type, group_default, explicit_default)
  defp example_value(type, nil, explicit_default) do
    case explicit_default do
      nil -> example_value!(type)
      _   -> explicit_default
    end
  end
  defp example_value(type, %Group{all_selected?: false}, explicit_default), do: example_value(type, nil, explicit_default)
  defp example_value(_type, %Group{all_selected?: true}, _), do: true


  defp example_value!(type) do
    if Map.has_key?(@defined_types, type) do
      Map.get(@defined_types, type)
    else
      raise Error, """
      Undefined XOpts type #{type}!
      Defined Types and their default values are:
      #{inspect @defined_types}
      """
    end
  end
end
