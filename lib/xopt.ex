defmodule Xopt do
  @moduledoc """
  Coming soon
  """

  @shortdoc "Xopt a wrapper around `OptParser`"

  defmacro __before_compile__(_env) do
    quote do
      Module.get_attribute( __MODULE__, :_option_definitions)
      def parse(args), do: Xopt.Parser.parse(args, @_option_definitions)
    end
  end
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_option_definitions, []
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro option(name, type, params \\ [])
  defmacro option(name, type, params) do
    quote bind_quoted: [name: name, type: type, params: params] do
      ods = Module.get_attribute __MODULE__, :_option_definitions
      Module.put_attribute __MODULE__, :_option_definitions, [{name, type, params} | ods]
    end
  end

end
