defmodule XOpts do


  defmacro __before_compile__(_env) do
    quote do
      # xoptions = XOpts.MacroState.get_xoptions(__MODULE__)
      # Module.put_attribute( __MODULE__, :_xoptions, xoptions)
      xoptions = Module.get_attribute( __MODULE__, :_xoptions)

      defmodule XOpts do
	defstruct unquote(__MODULE__).Tools.make_struct_def( xoptions |> IO.inspect )
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

  defmacro group(name, code)
  defmacro group(name, do: {:__block__, args, blox} = block) do
    blox1 = blox |> Enum.map( fn {x, y, [z]} -> {x, y, [z, group: name]} end )
    {:__block__, args, blox1}
  end
  defmacro group(name, do: {:option, line, [option_name]}) do
    {:option, line, [option_name, group: name]}
  end

end
