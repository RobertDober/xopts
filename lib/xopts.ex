defmodule XOpts do

  @moduledoc """
  ## Synopsis

  Define options to use a module as an `OptionParser.parse` frontend.

  Advantages:

    - Declarative Syntax.
    - Added possibilities like defaults, groups and constraints.
    - Returns a compile time created struct, local to the module using `XOpts`.


  ## Usage

  Use the `XOpts` module in your module

      defmodule MyMod do

        use XOpts

  then define options with the `options` macro.

        options :version, :string
        options :verbose, :boolean
        options :language, :string, "elixir"

  This will create a struct `MyMod.XOpts` with all defined options as keys and default values
  according to the options' type or explicitly defined default values.

  In the above case the injected `XOpts` module would contain the following code:

        defstruct [version: "", verbose: false, language: "elixir"]

  And a `parse` function is injected into `MyMod`
  its result will match the following

        %MyMod.XOpts{verbose: true, language: "erlang"} = MyMod.parse(~w(--verbose --language erlang))

  TODO:

  - Detailed description of the API, maybe including test files?
  """

  @typep xoption_tuple :: {atom(), atom(), atom(), atom()}
  @type t :: list(xoption_tuple)
  defmacro __before_compile__(_env) do
    quote do
      xoptions = Module.get_attribute( __MODULE__, :_xoptions )
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
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_xoptions, []

    end
  end

  @doc """
    Define an option by name, type and an optional default value.
  """
  defmacro option(name, definition, default \\ nil, group \\ nil)
  defmacro option(name, type, default, group) do
    quote bind_quoted: [default: default, group: group, name: name, type: type] do
      Module.put_attribute( __MODULE__, :_xoptions,
      [ {name, type, default, group} | Module.get_attribute( __MODULE__, :_xoptions ) ])
    end
  end

  @doc """
    Define an option that sets all boolean options of a group
  """
  defmacro group_option(name, group_def)
  defmacro group_option(name, [for: group]) do
    quote bind_quoted: [group: group, name: name] do
      Module.put_attribute( __MODULE__, :_xoptions,
      [ {:group_option, name, group, nil} | Module.get_attribute( __MODULE__, :_xoptions ) ])
    end
  end
  defmacro group_option(name, _) do
    quote bind_quoted: [name: name] do
      raise """
      Needed keyword param `for: group` missing for group_option #{name} in #{__FILE__}
      """
    end
  end

end
