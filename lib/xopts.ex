defmodule XOpts do


  defmacro __before_compile__(_env) do
    quote do
      # xoptions = XOpts.MacroState.get_xoptions(__MODULE__)
      # Module.put_attribute( __MODULE__, :_xoptions, xoptions)
      xoptions = Module.get_attribute( __MODULE__, :_xoptions)

      defmodule XOpts do
	defstruct unquote(__MODULE__).Tools.make_struct_def( xoptions )
          # [],
          # %{},
          # [args: nil, groups: %{}, is: %{valid: false}, options: %{}])
      end

      @doc """
      Injected function to allow to pass the `@_xoptions` module attribute to the real parsing
      function defined in unquote(__MODULE__).
      """
      def parse(args) do
	unquote(__MODULE__).Parser.parse(args, @_xoptions, __MODULE__.XOpts)
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute( __MODULE__, :_xoptions, accumulate: true )
    end
  end

  @doc """
    Define an option by name, type and an optional default value.
  """
  defmacro option(name, type \\ :boolean, opts \\ [] )
  defmacro option(name, {:group, group}, _) do
    quote bind_quoted: [group: group, name: name] do
      values = {name, :boolean, [group: group]}
      Module.put_attribute __MODULE__, :_xoptions, values
    end
  end
  defmacro option(name, type, opts) do
    quote bind_quoted: [name: name, opts: opts, type: type] do
      values = {name, type, opts}
      Module.put_attribute __MODULE__, :_xoptions, values
    end
  end

  defmacro group(name, do: code), do: _group(name, [], code)
  defmacro group(name, opts, do: code), do: _group(name, opts, code)
  
  defp _group(name, opts, {:__block__, args, blox} = block) do
    blox1 = blox |> Enum.map( fn {x, y, [z]} -> {x, y, [z, group: name]} end )
    {:__block__, args, blox1}
  end
  defp _group(group_name, opts, {:option, line, [option_name]}) do
    {:option, line, [option_name, group: group_name]} |> IO.inspect
  end
  defp _group(group_name, opts, {:options, line, [option_names]}) do
    {
      :__block__,
      [],
      option_names
      |> Enum.map(fn option_name -> {:option, line, make_group_options(option_name, group_name, opts)} end )
    }
  end

  defp make_group_options(option_name, group_name, _opts) do
    [option_name, group: group_name]
  end

  defp _normalize_group_options(grp_opts, forbidden, result)
  defp _normalize_group_options([], _, result), do: result
  defp _normalize_group_options([{:exclusive, true}|rest], forbidden, result) do
    # TODO: Provide more information about errors, lnbs?
    if MapSet.member?(forbidden, :exclusive) do
      raise Error, ":exclusive conflicts with other options"
    else
      _normalize_group_options(
        rest,
        MapSet.union(forbidden, MapSet.new([:allowed, :exclusive, :max, :min, :required])),
        [{:min, 0}, {:max, 1} | result])
    end
  end
  defp _normalize_group_options({:allowed, range}|rest], forbidden, result) do
    if MapSet.member?(forbidden, :allowed) do
      raise Error, ":allowed conflicts with other options"
    else
      _normalize_group_options(
        rest,
        MapSet.union(forbidden, MapSet.new([:allowed, :exclusive, :max, :min, :required])),
        [{:min, Enum.min(range)}, {:max, Enum.max(range)} | result])
    end
  end
  defp _normalize_group_options({:required, true}|rest], forbidden, result) do
    if MapSet.member?(forbidden, :required) do
      raise Error, ":required conflicts with other options"
    else
      _normalize_group_options(
        rest,
        MapSet.union(forbidden, MapSet.new([:allowed, :exclusive, :max, :min, :required])),
        [{:min, 1}, {:max, 1} | result])
    end
  end
  defp _normalize_group_options({:min, value}|rest], forbidden, result) do
    if MapSet.member?(forbidden, :min) do
      raise Error, ":min conflicts with other options"
    else
      case Keyword.get(result, :max) do
          nil -> _normalize_group_options(
          rest,
          MapSet.union(forbidden, MapSet.new([:allowed, :exclusive, :min, :required])),
        [{:min, value} | result])
        max ->

    end
  end

end
