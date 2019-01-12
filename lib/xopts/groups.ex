defmodule XOpts.Groups do

  alias XOpts.Group

  @doc """
  Extract groups and group_options from xoptions
  """
  def extract_groups(xoptions, switches, result)
  def extract_groups([], _, result), do: result
  def extract_groups([{:group_option, name, group, _}|rest], switches, result) do
    all_selected? = !!Keyword.get(switches, name, false) 
    extract_groups(
      rest,
      switches,
      add_group_with_selected(result, group, all_selected?))
  end
  def extract_groups([{name, type, :group, group} | rest], switches, result) do
    extract_groups(rest, switches, add_group_from_option(result, name, group, type))
  end
  def extract_groups([_|rest], switches, result), do: extract_groups(rest, switches, result)

  defp add_group_from_option(result, name, group_name, _type) do
    group1 = Map.get(result, group_name, %Group{})
    Map.put(result, group_name, %{group1 | values: Map.put(group1.values, name, nil)})
  end


  defp add_group_with_selected(result, group_name, all_selected?) do
    case Map.fetch(result, group_name) do
      {:ok, _} -> %{result | group_name => Map.put(result[group_name], :all_selected?, all_selected?)}
      :error   -> Map.put(result, group_name, %Group{all_selected?: all_selected?})
    end
  end
end
