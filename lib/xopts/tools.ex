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
  
  @doc """
  Extracts name and type from xoptions and creates an array to be passed into `defstruct`

  Essentially the type is replaced with a default value, either by the `opts` Keyword or
  by the type's default default value (pun intended).
  """
  def make_struct_def(xoptions), do: _make_struct_def(xoptions)

  defp _make_struct_def(tuple_or_list)
  defp _make_struct_def({_, _, _}=tol), do: _make_struct_def_element(tol)
  defp _make_struct_def(list), do: Enum.map(list, &_make_struct_def_element/1) 

  defp _make_struct_def_element({name, type, opts}) do
    # TODO: Reject illegal types
    case Keyword.get(opts, :default) do
      nil              -> {name, example_value!(type)}
      explicit_default -> {name, explicit_default}
    end
  end

  @spec make_options( XOpts.t, Keyword.t, map(), Keyword.t ) :: Keyword.t 
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
  
  @spec example_value( atom(), atom(), atom() ) :: atom()
  defp example_value(type, group_default, explicit_default)
  defp example_value(type, nil, explicit_default) do
    case explicit_default do
      nil -> example_value!(type)
      _   -> explicit_default
    end
  end
  defp example_value(type, %Group{all_selected?: false}, explicit_default), do: example_value(type, nil, explicit_default)
  defp example_value(_type, %Group{all_selected?: true}, _), do: true


  @spec example_value!( atom() ) :: atom()
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
