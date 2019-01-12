defmodule XOpts.Parser do

  import XOpts.Groups
  import XOpts.Tools

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


  defp make_strict(xoptions, result)
  defp make_strict([], result), do: result
  defp make_strict([{:group_option, name, _, _} | rest], result), do: make_strict(rest, [{name, :boolean} | result])
  defp make_strict([{name, type, _, _} | rest], result), do: make_strict(rest, [{name, type} | result])

  defp postprocess(xoptions, switches, args) do
    groups = extract_groups(xoptions, switches, %{})
    options = make_options(xoptions, switches, groups, []) |> Enum.into(%{})
    switches 
      |> Enum.into(%{args: args, groups: %{}, options: options, is: validate(xoptions,switches)})
      |> update_groups(groups)
  end

  defp update_group({group_name, group}, {result, acc}) do
    {result1, member_values} =
      Enum.reduce(group.values, {result, %{}}, &update_group_values/2)
    {result1, Map.put(acc, group_name, member_values)}
  end

  defp update_group_values({name, _type}, {result, acc}) do
    value = Map.get(result.options, name) 
    {Map.put(result, name, value), Map.put(acc, name, value)}
  end

  defp update_groups(result, groups) do
    # %{parser: %{leex: :boolean, recursive: :boolean, regex: :boolean}}
    {result1, updated_groups} =
      Enum.reduce(groups, {result, %{}}, &update_group/2)
    %{result1 | groups: updated_groups}
  end

  defp validate(xoptions, switches) do
    validate_switches(xoptions, switches, [])
  end

  defp validate_switches(xoptions, swiches, errors)
  defp validate_switches([], _switches, []), do: %{errors: [], valid: true}
  defp validate_switches([], _switches, errors), do: %{errors: errors, valid: false}
  defp validate_switches([{name, type, nil, :required}|rest], switches, errors) do
    case Keyword.get(switches, name) do
      nil -> validate_switches(rest, switches, ["Error, missing required option `#{name}:#{type}`"|errors])
      _ -> validate_switches(rest, switches, errors)
    end
  end
  defp validate_switches([_|rest], switches, errors), do: validate_switches(rest, switches, errors)

end
