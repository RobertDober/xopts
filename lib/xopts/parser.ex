defmodule Xopt.Parser do
  
  def parse(args, definitions) do
    IO.inspect(definitions)
    strict = extract_strict(definitions, [])
    parsed = OptionParser.parse(args, strict: strict)
    add_attributes(definitions, parsed, %{})
  end

  defp add_args(%{args: args} = result, %{min_args: min, max_args: max}) do
    unless min <= Enum.count(args) && max >= Enum.count(args) do
      Map.put(result, :errors, [{ "positional count #{Enum.count(args)} incorrect", {min, max} } | result.errors])
    end
  end
  defp add_attributes(definitions, {options, args, errors}, result) do
    result
    |> Map.put(:options, options |> Enum.into(%{}))
    |> Map.put(:args, args)
    |> Map.put(:errors, errors)
    |> add_args(definitions)
    |> validate(definitions)
    |> Map.put(:is, %{valid?: Enum.empty?(errors)})
  end

  defp extract_strict(definitions, result)
  defp extract_strict([], result), do: result
  defp extract_strict([{name, type, _}|rest], result), do: extract_strict(rest, [{name, type}|result])
  defp extract_strict([{name, type}|rest], result), do: extract_strict(rest, [{name, type}|result])

  defp validate(%{errors: []}=result, _), do: Map.put(result, :is, %{valid: true})
  defp validate(%{errors: _}=result, _), do: Map.put(result, :is, %{valid: false})
end
