defmodule XOpts.Parser do

  import XOpts.Tools, only: [make_options: 3]

  @moduledoc """
  Implements parsing of the arguments and its postprocessing
  """

  @doc """
  forwards `args` to `OptionParser.parse`, while the options are deduced from the `option` macro
  invocations inside the client module.

  Then the result is postprocessed according to the constraints defined by the macros exposed by
  `XOpts`.
  """
  def parse(args, xoptions, client_struct) do
    case OptionParser.parse(args, strict: make_strict(xoptions, [])) do
      {switches, args, []} ->
        {:ok, struct(client_struct, postprocess(xoptions, switches, args))}
        {_, _, errors} -> {:error, errors}
    end
  end

  defp add_group(groups, name, group, type) do
    group_map = Map.get(groups, group, %{}) |> Map.put(name, type)
    Map.put(groups, group, group_map)
  end

  defp extract_groups(xoptions, result)
  defp extract_groups([], result), do: result
  defp extract_groups([{name, type, :group, group} | rest], result),
    do: extract_groups(rest, add_group(result, name, group, type))
  defp extract_groups([_|rest], result), do: extract_groups(rest, result)

  defp make_strict(xoptions, result)
  defp make_strict([], result), do: result
  defp make_strict([{:group_option, name, _, _} | rest], result), do: make_strict(rest, [{name, :boolean} | result])
  defp make_strict([{name, type, _, _} | rest], result), do: make_strict(rest, [{name, type} | result])

  @validation %{valid: true, errors: []}
  defp postprocess(xoptions, switches, args) do
    options = make_options(xoptions, switches, []) |> Enum.into(%{})
    groups = extract_groups(xoptions, %{})
    switches 
      |> Enum.into(%{args: args, groups: %{}, options: options, is: validate(xoptions,switches,args, @validation)})
      |> update_groups(groups)
  end

  defp update_group(result, {group_name, members}, acc) do
    member_values =
      Enum.reduce(members, %{}, &update_group_values(result, &1, &2))
    Map.put(acc, group_name, member_values)
  end

  defp update_group_values(result, {name, _type}, acc) do
    value = Map.get(result.options, name) 
    Map.put(acc, name, value)
  end

  defp update_groups(result, groups) do
    # %{parser: %{leex: :boolean, recursive: :boolean, regex: :boolean}}
    updated_groups =
      Enum.reduce(groups, %{}, &update_group(result, &1, &2))
    %{result | groups: updated_groups}
  end

  defp validate(xoptions, switches, _args, validation) do
    validate_switches(xoptions, switches, [])
  end

  defp validate_switches(xoptions, swiches, errors)
  defp validate_switches([], _switches, []), do: @validation 
  defp validate_switches([], _switches, errors), do: %{errors: errors, valid: false}
  defp validate_switches([{name, type, nil, :required}|rest], switches, errors) do
    case Keyword.get(switches, name) do
      nil -> validate_switches(rest, switches, ["Error, missing required option `#{name}:#{type}`"|errors])
      _ -> validate_switches(rest, switches, errors)
    end
  end
  defp validate_switches([_|rest], switches, errors), do: validate_switches(rest, switches, errors)

end
