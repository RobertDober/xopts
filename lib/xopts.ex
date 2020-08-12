defmodule XOpts do
  alias XOpts.Options

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
      ...(7)>   allowed_keywords: %{
      ...(7)>     count: :int,
      ...(7)>     message: :string }}
      ...(7)> XOpts.parse(~W[hello count: 42])
      {:ok, %{switches: %{}, keywords: %{count: 42}, positionals: ~W[hello], errors: []}}

  Did you notice the type conversion of the `int` parameter?
  Of course you did!

  Now the user is alerted of misspelled or badly typed arguments:

      iex(8)> configuration = %{
      ...(8)>   allowed_keywords: %{
      ...(8)>     count: :int,
      ...(8)>     message: :string }}
      ...(8)> XOpts.parse(~W[hello cont: 42])
      {:error,
        %{switches: %{},
          keywords: %{}, 
          positionals: ~W[hello], 
          errors: [{:forbidden, keyword: "cont", value: 42}]}}

  She will also be alerted of badly typed arguments

      iex(9)> configuration = %{
      ...(9)>   allowed_keywords: %{
      ...(9)>     count: :int,
      ...(9)>     message: :string }}
      ...(9)> XOpts.parse(~W[hello cont: alpha])
      {:error, 
        %{switches: %{},
          keywords: %{},
          positionals: ~W[hello],
          errors: [{:invalid_type, keyword: "cont", value: "alpha", requested: :int}]}}

  #### Requiring and Typing Keyword Arguments

  Sometimes keyword arguments need to be present

      iex(10)> configuration = %{
      ...(10)>   requested_keywords: %{
      ...(10)>     n: :non_negative_int }}
      ...(10)> XOpts.parse(~W[n: 2])
      {:ok, %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: []}}

  and when they are not

      iex(11)> configuration = %{
      ...(11)>   requested_keywords: %{
      ...(11)>     n: :non_negative_int }}
      ...(11)> XOpts.parse(~W[n: 2])
      {:ok,
        %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: [{:missing, keyword: "n"}]}}

  or violate a constraint

      iex(12)> configuration = %{
      ...(12)>   requested_keywords: %{
      ...(12)>     n: :non_negative_int }}
      ...(12)> XOpts.parse(~W[n: 2])
      {:error,
        %{switches: %{},
          keywords: %{n: 2},
          positionals: [],
          errors: [{:constraint_violation, keyword: "n", value: -1, range: [0]}]}}

  #### A wild combination of errors

      iex(13)> configuration = %{
      ...(13)>    allowed_keywords: %{
      ...(13)>      lang: ~r(\A [[:alnum]]{2} \z)x},
      ...(13)>    requested_keywords: %{
      ...(13)>      base: :any},
      ...(13)>    allowed_switches: []}
      ...(13)> input = ~W[ --verbose lang: frr ]
      ...(13)> XOpts.parse(input, configuration)
      {:error,
        %{
          switches: %{},
          keywords: %{},
          positionals: [],
          errors: [
            {:forbidden, switch: "verbose"},
            {:missing, keyword: "base"},
            {:constraint_violation, keyword: "lang", value: "frr", constraint: ~r(\A [[:alnum]]{2} \z)x}]}}

  Which was, of course, completely unnecessary

      iex(13)> configuration = %{
      ...(13)>    allowed_keywords: %{
      ...(13)>      lang: ~r(\A [[:alnum]]{2} \z)x},
      ...(13)>    requested_keywords: %{
      ...(13)>      base: :any},
      ...(13)>    allowed_switches: []}
      ...(14)> input = ~W[ lang: fr --base zero cinq ]
      ...(14)> XOpts.parse(input, configuration)
      {:ok
        %{
          switches: %{},
          keywords: %{base: "zero", lang: "fr"},
          positionals: ~W[cinq],
          errors: []}}
  """

  def parse(input, options \\ []) do
    _parse(input, Options.new(options))
  end

  defp _parse(input, options)
  defp _parse(_input, _options), do: nil
end
