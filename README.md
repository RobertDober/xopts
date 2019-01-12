# XOpts


  ## Synopsis

Use macros to define a parse function (for a strict `OptionParser.parse` invocation)
returning a `%__MODULE__.Xopts{}` struct.

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

      %MyMod.XOpts{verbose: true, language: "erlang"} = MyMod.parse(~w(--verbose --language erlang)) 



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xopts` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xopts, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xopt](https://hexdocs.pm/xopt).


# LICENSE

