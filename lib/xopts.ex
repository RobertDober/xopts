defmodule XOpts do

  @moduledoc """
  # XOpts a Command Line Argument Parser on Steroids.

  ## Synopsis

  ### Basic Usage

  Let us dive right into the simplest, possible case:

      iex(1)> XOpts.parse([])
      {:ok, %{switches: %{}, keywords: %{}, positionals: [], errors: []}}

      iex(2)> XOpts.parse(~W[alpha beta gamma])
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[alpha beta gamma], errors: []}}

      iex(3)> XOpts.parse(~W[:verbose alpha level: 42 beta gamma])
      {:ok, %{switches: %{verbose: true}, keywords: %{level: "42"}, positionals: ~W[alpha beta gamma], errors: []}}

  Posix is widely used and although it is ugly (beauty lies you know in whose eyes), we can accept it by default

      iex(4)> XOpts.parse(~W[--verbose alpha --level 42 beta gamma])
      {:ok, %{switches: %{verbose: true}, keywords: %{level: "42"}, positionals: ~W[alpha beta gamma], errors: []}}

  However we do not need to:

      iex(5)> XOpts.parse(~W[--verbose alpha --level 42 beta gamma], posix: false)
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[--verbose alpha --level 42 beta gamma], errors: []}}

  For fairness we can also dissallow keyword style arguments:

      iex(6)> XOpts.parse(~W[:verbose alpha level: 42 beta gamma], keyword_style: false)
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[:verbose alpha level: 42 beta gamma], errors: []}}


  Of course, using the `XOpts` Parser without any configuration - meaning the default configuration -
  does not give us much value.


  ### Simple Configuration
  

  #### Restricting and Typing Keyword Arguments
  
  As we have seen in the examples configuration can be passed as keyword arguments, however for more
  complex configuration that might become tedious and we therefore will pass in a map.

      iex(7)> configuration = %{
      ...(7)>   allowed_keywords = %{
      ...(7)>     count: :int,
      ...(7)>     message: :string }}
      ...(7)> XOpts.parse(~W[hello count: 42]})
      {:ok, %{switches: %{}, keywords: %{count: 42}, positionals: ~W[hello], errors: []}}

  Did you notice the type conversion of the `int` parameter?
  Of course you did!

  Now the user is alerted of misspelled or badly typed arguments:

      iex(8)> @expected_errors  [{:forbidden, keyword: "cont", value: 42}]
      ...(8)> configuration = %{
      ...(8)>   allowed_keywords = %{
      ...(8)>     count: :int,
      ...(8)>     message: :string }}
      ...(8)> XOpts.parse(~W[hello cont: 42]})
      {:error, %{switches: %{}, keywords: %{}, positionals: ~W[hello], errors: @expected_errors}}

  She will also be alerted of badly typed arguments

      iex(9)> @expected_errors  [{:invalid_type, keyword: "cont", value: "alpha", requested: :int}]
      ...(9)> configuration = %{
      ...(9)>   allowed_keywords = %{
      ...(9)>     count: :int,
      ...(9)>     message: :string }}
      ...(9)> XOpts.parse(~W[hello cont: alpha]})
      {:error, %{switches: %{}, keywords: %{}, positionals: ~W[hello], errors: @expected_errors}}

  #### Requiring and Typing Keyword Arguments
  
  Sometimes keyword arguments need to be present

      iex(0)> configuration = %{
      ...(0)>   requested_keywords: %{
      ...(0)>     n: :non_negative_int }}
      ...(0)> XOpts.parse(~W[n: 2])
      {:ok, %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: []}}

  and when they are not

      iex(0)> @expected_errors [{:missing, keyword: "n"}]
      iex(0)> configuration = %{
      ...(0)>   requested_keywords: %{
      ...(0)>     n: :non_negative_int }}
      ...(0)> XOpts.parse(~W[n: 2])
      {:ok,
        %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: @expected_errors}}

  or violate a constraint

      iex(0)> @expected_errors [{:constraint_violation, keyword: "n", value: -1, range: [0]}]
      iex(0)> configuration = %{
      ...(0)>   requested_keywords: %{
      ...(0)>     n: :non_negative_int }}
      ...(0)> XOpts.parse(~W[n: 2])
      {:ok,
        %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: @expected_errors}}

  #### A wild combination of errors

      iex(0)> @expected_errors [
      ...(0)> {:forbidden, switch: "verbose"},
      ...(0)> {:missing, keyword: "base"},
      ...(0)> {:constraint_violation, keyword: "lang", value: "frr", constraint: ~r(\A [[:alnum]]{2} \z)x} ]
      ...(0)> configuration = %{
      ...(0)>    allowed_keywords: %{
      ...(0)>      lang: ~r(\A [[:alnum]]{2} \z)x}}
      ...(0)>    requested_keywords: %{
      ...(0)>      base: :any},
      ...(0)>    allowed_switches: []}
      ...(0)> input = ~W[ --verbose lang: frr ]
      ...(0)> XOpts.parse(input, configuration)
      {:error,
        %{
          switches: %{},
          keywords: %{},
          positionals: [],
          errors: @expected_errors}}

  Which was, of course, completely unnecessary

      ...(0)> configuration = %{
      ...(0)>    allowed_keywords: %{
      ...(0)>      lang: ~r(\A [[:alnum]]{2} \z)x}}
      ...(0)>    requested_keywords: %{
      ...(0)>      base: :any},
      ...(0)>    allowed_switches: []}
      ...(0)> input = ~W[ lang: fr --base zero cinq ]
      ...(0)> XOpts.parse(input, configuration)
      {:ok
        %{
          switches: %{},
          keywords: %{base: "zero", lang: "fr"},
          positionals: ~W[cinq],
          errors: []}}

  """


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
