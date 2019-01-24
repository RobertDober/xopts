defmodule XOpts do


  defmacro __before_compile__(_env) do
    quote do
      xoptions = XOpts.MacroState.get_xoptions(__MODULE__)
      Module.put_attribute( __MODULE__, :_xoptions, xoptions)

      defmodule XOpts do
	defstruct unquote(__MODULE__).Tools.make_options(
          xoptions,
          [],
          %{},
          [args: nil, groups: %{}, is: %{valid: false}, options: %{}])
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
      Module.register_attribute( __MODULE__, :_xoptions, [] )
      XOpts.MacroState.start_link __MODULE__ 
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
    Define an option by name, type and an optional default value.
  """
  defmacro option(name, definition, default \\ nil, group \\ nil)
  defmacro option(name, type, default, group) do
    quote bind_quoted: [default: default, group: group, name: name, type: type] do
      {group1, xoptions} = XOpts.MacroState.get_state(__MODULE__)
      group2 = group1 || group
      values = {name, type, :group , group2}
      XOpts.MacroState.add_xoption(__MODULE__, values)
    end
  end

  defmacro group(name, do: block) do
    quote bind_quoted: [block: block, name: name] do
      XOpts.MacroState.set_group(__MODULE__, name)
      block
      XOpts.MacroState.set_group(__MODULE__, nil)
    end
  end

end
