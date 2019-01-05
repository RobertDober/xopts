defmodule XOpts do

  @moduledoc """
  Coming soon
  """

  @defined_types %{
    boolean: false,
    float: 0.0,
    integer: 0,
    string: "",
  }


  defmacro __before_compile__(_env) do
    quote do
      xoptions = Module.get_attribute( __MODULE__, :_xoptions )
      defmodule XOpts do
	defstruct unquote(__MODULE__).make_struct(xoptions, [])
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_xoptions, [] 

      @doc """
      Injected function to allow to pass the `@_xoptions` module attribute to the real parsing
      function defined in unquote(__MODULE__).
      """
      def parse(args) do
	unquote(__MODULE__).parse(args, @_xoptions)
      end
    end
  end

  defmacro option(name, definition)
  defmacro option(name, {type, default}) do
    quote bind_quoted: [default: default, name: name, type: type] do
      Module.put_attribute( __MODULE__, :_xoptions,
      [ {name, type, default, nil} | Module.get_attribute( __MODULE__, :_xoptions ) ])
    end
  end
  defmacro option(name, type) do
    quote bind_quoted: [name: name, type: type] do
      Module.put_attribute( __MODULE__, :_xoptions,
      [ {name, type, nil, nil} | Module.get_attribute( __MODULE__, :_xoptions ) ])
    end
  end

  @doc "not for the public API, but calls are injected into the client module"
  def make_struct(xoptions, result)
  def make_struct([], result), do: result
  def make_struct([{name, type, nil, _}|rest], result) do
    make_struct(rest, [{name, example_value(type)} | result])
  end
  def make_struct([{name, type, default, _}|rest], result) do
    make_struct(rest, [{name, default} | result])
  end

  @doc """
  forwards `args` to `OptionParser.parse`, while the options are deduced from the `option` macro
  invocations inside the client module.
  """
  def parse(args, xoptions) do
    OptionParser.parse(args, strict: make_strict(xoptions))
  end

  defp example_value(type) do
    if Map.has_key?(@defined_types, type) do
      Map.get(@defined_types, type)
    else
      raise """
      Undefined XOpts type #{type}!
      Defined Types and their default values are:
      #{inspect @defined_types}
      """
    end
  end

  defp make_strict(xoptions) do
  end
end
